cy.input = (key) => {
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
}

cy.loadSong = () => {
	cy.fixture('sample.ogg', 'binary').then((song) => {
		var base64 = btoa(song)
		cy.window().invoke('cypress', {command: 'loadSong', song: 'data:audio/ogg;base64,' + base64, name: 'sample.ogg'})

		cy.contains('sample.ogg')
	})
}

cy.loadGame = () => {
	cy.fixture('sample.AMG', 'binary').then((game) => {
		var base64 = btoa(game)
		cy.window().invoke('cypress', {command: 'loadGame', game: base64})

		cy.contains('Failed to load')
	})
}

context('SDAE', () => {
	beforeEach(() => {
		cy.visit('/')
	})

	describe('game manager', () => {
		it('can manage game file using keyboard', () => {
			cy.contains('New Game')
			cy.input('n')

			cy.contains('Export Game') // can not run tests involving file dialog at the moment
			cy.contains('Unload Game')
			cy.input('g')

			cy.contains('New Game')
		})

		it('can manage game file using buttons', () => {
			cy.contains('New Game').click()

			cy.contains('Export Game') // can not run tests involving file dialog at the moment
			cy.contains('Unload Game').click()

			cy.contains('New Game')
		})

		it('can load game', () => {
			cy.loadGame()
		})
	})

	describe('hit editor', () => {
		it('can edit hits using keyboard', () => {
			cy.input('KeyF')
			cy.input('KeyD')
			cy.input('KeyS')
			cy.input('KeyJ')
			cy.input('KeyK')
			cy.input('KeyL')

			cy.get('main').contains('f').parent().should('have.prop', 'checked', true)
			cy.get('main').contains('d').parent().should('have.prop', 'checked', true)
			cy.get('main').contains('s').parent().should('have.prop', 'checked', true)
			cy.get('main').contains('j').parent().should('have.prop', 'checked', true)
			cy.get('main').contains('k').parent().should('have.prop', 'checked', true)
			cy.get('main').contains('l').parent().should('have.prop', 'checked', true)

			cy.input('KeyF')
			cy.input('KeyD')
			cy.input('KeyS')
			cy.input('KeyJ')
			cy.input('KeyK')
			cy.input('KeyL')

			cy.get('main').contains('f').parent().should('have.prop', 'checked', false)
			cy.get('main').contains('d').parent().should('have.prop', 'checked', false)
			cy.get('main').contains('s').parent().should('have.prop', 'checked', false)
			cy.get('main').contains('j').parent().should('have.prop', 'checked', false)
			cy.get('main').contains('k').parent().should('have.prop', 'checked', false)
			cy.get('main').contains('l').parent().should('have.prop', 'checked', false)
		})

		it('can edit hits using buttons', () => {
			cy.get('main').contains('f').parent().click().should('have.prop', 'checked', true)
			cy.get('main').contains('d').parent().click().should('have.prop', 'checked', true)
			cy.get('main').contains('s').parent().click().should('have.prop', 'checked', true)
			cy.get('main').contains('j').parent().click().should('have.prop', 'checked', true)
			cy.get('main').contains('k').parent().click().should('have.prop', 'checked', true)
			cy.get('main').contains('l').parent().click().should('have.prop', 'checked', true)

			cy.get('main').contains('f').parent().click().should('have.prop', 'checked', false)
			cy.get('main').contains('d').parent().click().should('have.prop', 'checked', false)
			cy.get('main').contains('s').parent().click().should('have.prop', 'checked', false)
			cy.get('main').contains('j').parent().click().should('have.prop', 'checked', false)
			cy.get('main').contains('k').parent().click().should('have.prop', 'checked', false)
			cy.get('main').contains('l').parent().click().should('have.prop', 'checked', false)
		})
	})

	describe('player', () => {
		beforeEach(() => {
			cy.loadSong()
		})

		it('can load songs', () => {
			cy.contains('⏸')
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)
		})

		it('can play / pause songs', () => {
			cy.contains('⏸').click()
			cy.contains('⏯').click()

			cy.input('Space')
			cy.contains('⏯')
			cy.input('Space')
			cy.contains('⏸')
		})

		it('can go to the beginning of the song', () => {
			cy.contains('⏮').click()
			cy.contains('⏯')
			cy.get('nav input[type="range"]').should('have.prop', 'value', '0')
		})

		it('can go to the end of the song', () => {
			cy.contains('⏭').click()
			cy.contains('⏯')
			cy.get('nav input[type="range"]').should('have.prop', 'value', '0')
		})

		it('can seek backward / forward using button', () => {
			cy.contains('⏮').click()

			cy.contains('⏩').click()
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('not.be.eq', '0')
			cy.contains('⏪').click()
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
		})

		it('can seek backward / forward using keyboard', () => {
			cy.contains('⏮').click()

			cy.input('ArrowRight')
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('not.be.eq', '0')
			cy.input('ArrowLeft')
			cy.get('nav input[type="range"]').should('have.prop', 'value', '0')
		})
	})
})
