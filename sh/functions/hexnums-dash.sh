hexnums-dash()
{
    ${SED-sed} "s,[0-9A-Fa-f][0-9A-Fa-f],&-\\\\?,g"
}
