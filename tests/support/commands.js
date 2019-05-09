Cypress.Commands.add('input', (key) => {
	cy.document().then((d) => {
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

Cypress.Commands.add('loadSong', (key) => {
	cy.fixture('sample.ogg', 'binary').then((song) => {
		var base64 = btoa(song)
		cy.window().invoke('cypress', {command: 'loadSong', song: 'data:audio/ogg;base64,' + base64, name: 'sample.ogg'})

		cy.contains('sample.ogg')
	})
})

Cypress.Commands.add('loadGame', (key) => {
	cy.fixture('sample.AMG', 'binary').then((game) => {
		var base64 = btoa(game)
		cy.window().invoke('cypress', {command: 'loadGame', game: base64})

		cy.contains('Failed to load')
	})
})
