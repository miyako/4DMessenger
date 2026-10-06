let avatar_path = '';

// menu crate download
function crateDownload(hash) {

    console.log(`(>'')> hash > ${hash}`);

    const crate = document.querySelector(`a[data-hash = '${hash}']`);
    const codex = parseInt(crate.dataset.codex);
    let contents = '';

    switch ( codex ) {

        case 3:
            contents = crate.querySelector('img').src;
            break;

        case 4:
            contents = crate.querySelector('video').src;
            break;

        case 5:
            contents = crate.querySelector('img').dataset.srcm;
            break;

    }

    return {'title':crate.querySelector('label').innerText,'codex':codex, 'contents':contents};

}

function avatarPathSet(path) {
    
    avatar_path = 'file://' + encodeURI(path) + '/';

}