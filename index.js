import {Howl, Howler} from 'howler';
import {Elm} from './src/Main.elm';
import {timeout} from "q";

const app = Elm.Main.init({
    node:  document.getElementById('app'),
    flags: {}
});

var song = null;
var isPlaying = false;
var posTimeout = 100;

app.ports.toJs.subscribe(function (json) {
    console.log(json);

    switch (json.command) {
        case 'load':
            load(json);
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
    song = new Howl({
        src: [json.song],
        onload: function(){
            toElm('duration');
        },
        onplay: function() {
            isPlaying = true;
            toElm('isPlaying');
            setTimeout(sendPos, posTimeout);
        },
        onpause: function() {
            isPlaying = false;
            toElm('isPlaying');
        },
        onend: function() {
            isPlaying = false;
            toElm('isPlaying');
        },
        onstop: function() {
            isPlaying = false;
            toElm('isPlaying');
        },
        onseek: function() {
            toElm('pos');
        }
    });

    playPause();
}

function begin() {
    song.stop();
}

function backward() {
    song.seek(song.seek() - 1);
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
    song.seek(song.seek() + 1);
}

function end() {
    song.stop();
}

function seek(json) {
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
        case 'duration':
            payload.duration = song.duration();
            break;
        case 'pos':
            payload.pos = song.seek();
            break;
    }

    console.log(payload);
    app.ports.toElm.send(payload);
}
