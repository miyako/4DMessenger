
function drawMessage (update) {

    // declare vars

    const chat_container = document.getElementById('chat_container');

    let div, message, messageFullDrawing;

    // actions
    if ( !update ) {

        // clear order
        chat_container.innerHTML = '';

    } else {

        // new div time message
        const curentCodeTime = codeTime (update.date, update.time);
        const divs = document.querySelectorAll('div.ss_message_time');
        const matchingDiv = Array.from(divs).find(div => div.textContent.trim() === curentCodeTime);

        if (!matchingDiv) {
            const message_time = document.createElement('div');
            message_time.classList.add('ss_message_time');
            message_time.innerText = curentCodeTime;
            chat_container.appendChild(message_time);
        }

        console.log(update);

        // new div message
        switch (update.way) {
            case 1: 
    
                // test if already receive
                if (document.getElementById(update.id + '-I')) {

                    message = document.getElementById(update.id + '-I');
                    messageFullDrawing = false;

                } else {

                    // not here make it
                    message = document.createElement('div');
                    message.setAttribute('id', update.id + '-I');
                    message.classList.add('ss_message', 'ss_message_in');
                    messageFullDrawing = true;

                }

                // add avatar image of sender
                const avatar_img_send = document.createElement('img');
                avatar_img_send.classList.add('ss_message_avatar');
                avatar_img_send.src = avatar_path + update.sender + '.png';
                avatar_img_send.alt = update.sender;
                avatar_img_send.title = update.sender;
                message.prepend(avatar_img_send);
                break;

            case 2: 

                // test if already send
                if (document.getElementById(update.id + '-O')) {

                    // already here update user reception only
                    message = document.getElementById(update.id + '-O');
                    messageFullDrawing = false;

                } else {

                    // not here make it
                    message = document.createElement('div');
                    message.setAttribute('id', update.id + '-O');
                    message.classList.add('ss_message', 'ss_message_out');
                    messageFullDrawing = true;

                }

                // add avatar image of receipt
                const avatar_img = document.createElement('img');
                avatar_img.classList.add('ss_message_avatar');
                avatar_img.src = avatar_path + update.recipient + '.png';
                avatar_img.alt = update.recipient;
                avatar_img.title = update.recipient;
                message.prepend(avatar_img);
                break;

            }

        // draw message contents
        if (messageFullDrawing) {

            const message_cargo = document.createElement('div');
            let message_crate = '';
            let label = '';

            update.cargo.forEach(crate => {

                // make create
                const codex = parseInt(crate.codex);
                if ( codex > 2 ) {
                
                    // make crate
                    message_crate = document.createElement('a');
                    message_crate.dataset.hash = crate.hash;
                    message_crate.dataset.codex = codex;
                    message_crate.classList.add('ss_message_crate');
                    message_crate.href = 'callContextMenu?' + JSON.stringify({
                            'title': crate.title,
                            'hash': crate.hash
                    });
                    message_crate.addEventListener("contextmenu", (event) => {

                        // remap context menu click
                        event.preventDefault();

                        const linkClick = new MouseEvent("click", {
                        bubbles: true,
                        cancelable: true,
                        view: window
                        });

                        event.target.dispatchEvent(linkClick);

                    });

                }
                
                switch (codex) {

                case 2:

                    // add contents message
                    const message_text = document.createElement('p');
                    message_text.innerText = crate.contents;
                    message.appendChild(message_text);
                    break;

                case 3:

                    // add contents to crate
                    const img = document.createElement('img');
                    img.src = crate.contents;
                    img.classList.add('ss_preview');
                    message_crate.appendChild(img);

                    // make crate label
                    label = document.createElement('label');
                    label.innerText = crate.title;
                    message_crate.appendChild(label);

                    // add crate to cargo
                    message_cargo.appendChild(message_crate);
                    break;

                case 4:

                    // add contents to crate
                    const video = document.createElement('video');
                    video.src = crate.contents;
                    video.classList.add('ss_preview');
                    message_crate.appendChild(video);

                    // make crate label
                    label = document.createElement('label');
                    label.innerText = crate.title;
                    message_crate.appendChild(label);

                    // add crate to cargo
                    message_crate.appendChild(label);
                    message_cargo.appendChild(message_crate);
                    break;

                case 5:

                    // add contents to crate
                    const other = document.createElement('img');
                    other.src = '../images/lists/List_File_Win.svg';
                    other.dataset.srcm = crate.contents;
                    other.classList.add('ss_preview');
                    message_crate.appendChild(other);

                    // make crate label
                    label = document.createElement('label');
                    label.innerText = crate.title;
                    message_crate.appendChild(label);

                    // add crate to cargo
                    message_cargo.appendChild(message_crate);
                    break;

                }

            });

            // add to history
            message.appendChild(message_cargo);
            chat_container.appendChild(message);

        }

        // show item
        scrollTarget((update.way === 1) ? update.id + '-I' : update.id + '-O');

    }
}

function scrollTarget (id) {

    document.getElementById(id).scrollIntoView({ behavior: "smooth", block: "start" });

}

function clearOutput() {

    chat_container.innerHTML = '';

}

function codeTime (isoString, timeNumber) {

    // date
    const date = new Date(isoString);
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const dayName = days[date.getUTCDay()];
    const day = date.getUTCDate();
    const month = months[date.getUTCMonth()];
    const year = date.getUTCFullYear();

    // time
    const hours = Math.floor(timeNumber / 3600);
    const minutes = Math.floor((timeNumber % 3600) / 60);

    const hh = String(hours).padStart(2, '0');
    const mm = String(minutes).padStart(2, '0');

    return `${dayName} ${day} ${month} ${year} at ${hh}:${mm}`;

}
