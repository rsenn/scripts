import sys
import certifi
import urllib3
import time
import logging
from bs4 import BeautifulSoup

http = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())

BASE_URL = "https://bs.to/"
PARSER = 'lxml'


def load_links(series_url, preferred_hosts, startepisode, endepisode):
    series_overview_soup = get_website(series_url)
    episodes = get_episodes(series_overview_soup, preferred_hosts)
    logging.info('found {:d} episodes.'.format(len(episodes)))
    stream_urls = []
    for episode in episodes:
        episode_number = episode['number']
        if startepisode <= episode_number <= endepisode:
            hoster_soup = get_website(episode['host_url'])
            stream_urls += [get_stream_url(hoster_soup)]
    return stream_urls


def get_stream_url(episode_soup):
    link = episode_soup.find(class_='hoster-player')
    return link['href']


def get_website(url):
    success = False
    while not success:
        response = http.urlopen('GET', url, preload_content=False, decode_content=True)
        if is_error_response(response):
            logging.error('Received Error-Code {}, trying again.'.format(response.status))
            time.sleep(1)
        else:
            success = True
    return BeautifulSoup(response.read().decode('utf-8'), PARSER)


def is_error_response(response):
    return response.status >= 400


def get_episodes(soup, preferred_hosts):
    episode_rows = soup.find('table', class_='episodes').find_all('tr')
    episodes = []

    for row in episode_rows:
        episode = dict()
        data_fields = row.find_all('td')
        episode['number'] = int(data_fields[0].string)
        if len(data_fields) < 3:
            logging.error('no hoster for episode {:d} found'.format(episode['number']))
            continue
        else:
            hoster_links = data_fields[2].find_all('a')
            episode['host_url'] = BASE_URL + find_preferred_host(hoster_links, preferred_hosts)
            episodes += [episode]

    return episodes


def find_preferred_host(hoster_links, preferred_hosts):
    for host in preferred_hosts:
        for link in hoster_links:
            if link['title'].lower() == host:
                return link['href']
    return hoster_links[0]['href']


if __name__ == "__main__":
    logging.basicConfig(filename='parser.log', level=logging.INFO)

    if len(sys.argv) < 2:
        print('USAGE: <url of series> [-p <preffered hoster, seperated by comma>] [-f <output file>] [-s <startepisode>] [-e <endepisode>]')
        exit(1)

    series_url = sys.argv[1]
    if '-p' in sys.argv:
        preferred_hosts = [s.lower() for s in sys.argv[sys.argv.index('-p') + 1].split(',')]
    else:
        preferred_hosts = []
    if '-f' in sys.argv:
        outfile = sys.argv[sys.argv.index('-f') + 1]
    else:
        outfile = ''
    if '-s' in sys.argv:
        startepisode = int(sys.argv[sys.argv.index('-s') + 1])
    else:
        startepisode = 1
        
    if '-e' in sys.argv:
        endepisode = int(sys.argv[sys.argv.index('-e') + 1])
    else:
        endepisode = 10_000

    logging.info('Passed arguments:\npreferred hosts: {}\noutput file: {}\nstartepisode: {}\nendepisode: {}'.format(
        ', '.join(preferred_hosts), outfile, startepisode, endepisode
    ))

    try:
        stream_urls = load_links(series_url, preferred_hosts, startepisode, endepisode)
    except Exception as e:
        logging.exception(e)
        raise e

    output = '\n'.join(stream_urls)
    if len(outfile) == 0:
        print(output)
    else:
        with(open(outfile, 'w')) as file:
            file.write(output)
