# SDAE

## Github hosted version

You can access a build of this projet at https://mdevlamynck.github.io/sdae/.

## Run locally

To run the projet locally in your browser you first need to build it:

```
npm i         # Installs dependencies
npm run build # Builds project
```

You can then open the `dist/index.html` file in your favorite web browser for example:

```
firefox dist/index.html
```

## Usefull commands to hack on the project

```
npm i                     # Install dependencies
npm run serve             # Builds the project and run on http://localhost:1234
npm run test              # Runs tests
npm run e2e               # Runs end to end tests (requires that the project runs with npm run serve)
npm run cypress           # Opens cypress e2e tests
npm run bench             # Builds the benchmarks to the bench.html file (open it in a browser to run the benchs)
npm run amg-test "<file>" # Tries to decode and reencode the given file then compares the output to the original
```

## Notes

Spec of the file format to generate: https://github.com/AltoRetrato/samba-de-amigo-2k_modding/blob/master/docs/Samba%20de%20Amigo%20ver.%202000%20-%20AMG%20file%20format.txt
