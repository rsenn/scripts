js-try-module () 
{ 
    $1 -e "globalThis.M = await import('${2}').catch(() => {});"' process.exit((!M)|0);'
}

node-try-module () 
{ 
    js-try-module 'node' "$@"
}

bun-try-module () 
{ 
    js-try-module 'bun' "$@"
}

qjs-try-module () 
{ 
    js-try-module 'qjs' "$@"
}

deno-try-module () 
{ 
    deno eval "globalThis.M = await import('jsr:${1}').catch(() => {});"' process.exit((!M)|0);'
}
