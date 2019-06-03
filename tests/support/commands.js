Cypress.Commands.add('input', {prevSubject: false}, (key) => {
    const log = Cypress.log({});
	cy.document({log: false}).then((d) => {
		d.dispatchEvent(
			new KeyboardEvent(
				"keydown",
				{
					key : key,
					code : key,
				}
			)
		)
	})
})

Cypress.Commands.add('loadSong', {prevSubject: false}, () => {
	const log = Cypress.log({});
	cy.fixture('sample.ogg', 'binary', {log: false}).then((song) => {
		var base64 = btoa(song)
		cy.window({log: false}).invoke('cypress', {command: 'loadSong', song: 'data:audio/ogg;base64,' + base64, name: 'sample.ogg'})

		cy.contains('sample.ogg', {log: false})
	})
})

Cypress.Commands.add('loadGame', {prevSubject: false}, () => {
	const log = Cypress.log({});
	cy.fixture('sample.AMG', 'binary', {log: false}).then((game) => {
		var base64 = btoa(game)
		cy.window({log: false}).invoke('cypress', {command: 'loadGame', game: base64})

		cy.contains('Unload Game', {log: false})
	})
})

Cypress.Commands.add('newGame', {prevSubject: false}, () => {
	cy.input('p');
	cy.input('n');
})
