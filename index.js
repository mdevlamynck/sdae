import { Howl, Howler } from 'howler';
import { Elm } from './src/Main.elm';

const app = Elm.Main.init({
	node: document.getElementById('app'),
	flags: {}
});

var song = null;

app.ports.toJs.subscribe(function (json) {
	console.log(json);

	switch (json.command) {
		case 'open':
			song = new Howl({src: './' + json.file});
			song.play();
			break;
		case 'begin':
			break;
		case 'backward':
			break;
		case 'playPause':
			if (song !== null) {
				song.play();
			}
			break;
		case 'forward':
			break;
		case 'end':
			break;
	}
});
