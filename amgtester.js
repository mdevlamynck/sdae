import fs from 'fs';
import {Elm} from './src/AMGTester.elm';

const app = Elm.AMGTester.init();

app.ports.sendToJs.subscribe(console.log);

const file = fs.readFileSync(process.argv[2], { encoding: 'base64' });
app.ports.sendToElm.send(file);
