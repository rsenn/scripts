node-try-module () 
{ 
    node -e "globalThis.M = await import('${1}').catch(() => {});"' process.exit((!M)|0);'
}
