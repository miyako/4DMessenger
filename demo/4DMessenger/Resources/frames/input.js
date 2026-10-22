
// mem target
const message_container = document.getElementById('message_container');
const message_cargo = document.getElementById('message_cargo');
const message_text = document.getElementById('message_text');

const MAX_SIZE = 64 * 1024 * 1024;

// strings in the 4D UI language (setStrings is called by 4D when the page is loaded)
let strings = {
    'fileTooLarge': 'The file cannot be added: it is larger than {max} MB.'
};

function setStrings(localized) {
    Object.assign(strings, localized);
    if (strings.placeholder) {
        message_text.placeholder = strings.placeholder;
    }
}

// event drag on
['dragenter', 'dragover'].forEach(event => {
    message_text.addEventListener(event, e => {
        e.preventDefault();
        e.stopPropagation();
        message_text.classList.add('ss_dragover');
    });
});

// event drag off
['dragleave', 'drop'].forEach(event => {
    message_text.addEventListener(event, e => {
        e.preventDefault();
        e.stopPropagation();
        message_text.classList.remove('ss_dragover');
    });
});

// event drop
message_text.addEventListener('drop', async (event) => {

    // parce list
    const files = event.dataTransfer.files;
    for (const file of files) {

        if ( file.size > MAX_SIZE ) {

            alert(strings.fileTooLarge.replace('{max}', MAX_SIZE / 1024 / 1024));

        } else {

            // generate hash
            const arrayBuffer = await file.arrayBuffer();
            const hashBuffer = await crypto.subtle.digest("SHA-256", arrayBuffer);
            const hashArray = Array.from(new Uint8Array(hashBuffer));
            const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');

            // file not present in cargo add it
            if ( Array.from(document.querySelectorAll('a')).filter(link => link.dataset.hash === hashHex).length === 0 ) {

                // get data type
                const dataType = file.type.split('/', 1)[0];

                // open reader
                const reader = new FileReader();
                reader.onload = function(event) {

                    // make crate div 
                    const link = document.createElement('a');
                    link.dataset.hash = hashHex;
                    link.classList.add('ss_message_crate');
                    link.href = 'callContextMenu?' + JSON.stringify({
                        'title': file.name,
                        'hash': hashHex
                    });
                    link.addEventListener("contextmenu", (event) => {

                        // remap context menu click
                        event.preventDefault();

                        const linkClick = new MouseEvent("click", {
                        bubbles: true,
                        cancelable: true,
                        view: window
                        });

                        event.target.dispatchEvent(linkClick);

                    });

                    // make crate preview
                    switch (dataType) {

                        case 'image':

                            const img = document.createElement('img');
                            img.src = event.target.result;
                            img.innerHTML = '';
                            img.classList.add('ss_preview');
                            link.dataset.codex = 3;
                            link.appendChild(img);
                            break;

                        case 'video':

                            const video = document.createElement('video');
                            video.src = event.target.result;
                            video.innerHTML = '';
                            video.classList.add('ss_preview');
                            link.dataset.codex = 4;
                            link.appendChild(video);
                            break;
 
                        default:

                            const other = document.createElement('img');
                            other.src = '../images/lists/List_File_Win.svg';
                            other.dataset.srcm = event.target.result;
                            other.innerHTML = '';
                            other.classList.add('ss_preview');
                            link.dataset.codex = 5;
                            link.appendChild(other);
                            break;

                    }

                    // make crate label
                    const label = document.createElement('label');
                    label.innerText = file.name;
                    link.appendChild(label);

                    // relase crate
                    message_cargo.appendChild(link);

                };
                reader.readAsDataURL(file);

            }

        }
    }

});

// menu crate delete
function crateDelete(hash) {

    if ( !hash ) {

        // erase many
        document.querySelectorAll('a[data-hash]').forEach(el => el.remove());

    } else {
    
        // erase one
        document.querySelectorAll(`a[data-hash = '${hash}']`).forEach(el => el.remove());
   
    }
    
}

// clear input
function clearInput() {

    message_text.value = '';
    message_cargo.innerHTML = '';

    message_text.focus();
    message_text.setSelectionRange(0, 0);
}

// grab cargo to 4D
function grabCargo () {

    // declare var
    let cargo = [];
    let contents = '';

    // loop on crate
    document.querySelectorAll(`a[data-hash]`).forEach( crate => {

        const codex = parseInt(crate.dataset.codex);
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

        cargo.push({
            'title': crate.getElementsByTagName('label')[0].innerText,
            'hash': crate.dataset.hash,
            'codex': codex,
            'contents': contents
        });

    });

    // add main message
    cargo.push({
        'title': '',
        'hash': '',
        'codex': 2,
        'contents': document.getElementById('message_text').value
    });

   return cargo;

}
