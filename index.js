
import {Howl, Howler} from 'howler';
import {Elm} from './src/Main.elm';

const app = Elm.Main.init({
    node:  document.getElementById('app'),
    flags: {}
});

// For Tests
window.cypress = (json) => {
    console.log(json);
    app.ports.cypress.send(json);
};

var song = null;
var isPlaying = false;
var posTimeout = 100;

app.ports.toJs.subscribe((json) => {
    console.log(json);

    switch (json.command) {
        case 'load':
            load(json);
            break;
        case 'unload':
            unload();
            break;
        case 'begin':
            begin();
            break;
        case 'backward':
            backward();
            break;
        case 'playPause':
            playPause();
            break;
        case 'forward':
            forward();
            break;
        case 'end':
            end();
            break;
        case 'seek':
            seek(json);
            break;
    }
});

function load(json) {
    var loading = new Howl({
        src: [json.song],
        onload: function() {
            song = loading;
            toElm('songLoaded');
            toElm('pos');

            playPause();
        },
        onloaderror: console.log,
        onplay: function() {
            isPlaying = true;
            toElm('isPlaying');
            setTimeout(sendPos, posTimeout);
        },
        onpause: function() {
            isPlaying = false;
            toElm('isPlaying');
            toElm('pos');
        },
        onend: function() {
            isPlaying = false;
            toElm('isPlaying');
            toElm('pos');
        },
        onstop: function() {
            isPlaying = false;
            toElm('isPlaying');
            toElm('pos');
        },
        onseek: function() {
            toElm('pos');
        }
    });
}

function unload() {
    if (song === null) {
        return;
    }

    song.unload();
    song = null;
}

function begin() {
    if (song === null) {
        return;
    }

    song.stop();
}

function backward() {
    if (song === null) {
        return;
    }

    song.seek(Math.max(song.seek() - 1, 0));
}

function playPause() {
    if (song === null) {
        return;
    }

    if (isPlaying) {
        song.pause();
    } else {
        song.play();
    }
}

function forward() {
    if (song === null) {
        return;
    }

    song.seek(Math.min(song.seek() + 1, song.duration()));
}

function end() {
    if (song === null) {
        return;
    }

    song.stop();
}

function seek(json) {
    if (song === null) {
        return;
    }

    song.seek(json.pos);
}

function sendPos() {
    toElm('pos');
    console.log(isPlaying);
    if (isPlaying) {
        setTimeout(sendPos, posTimeout);
    }
}

function toElm(command) {
    var payload = {command: command};

    switch (command) {
        case 'isPlaying':
            payload.isPlaying = isPlaying;
            break;
        case 'songLoaded':
            payload.duration = song.duration();
            break;
        case 'pos':
            if (song === null) {
                return;
            }

            payload.pos = song.seek();
            break;
    }

    console.log(payload);
    app.ports.toElm.send(payload);
}
