context('game manager', () => {
	beforeEach(() => {
		cy.visit('/')
	})

	it('can manage new game file using buttons', () => {
		cy.contains('New Game').click()

		cy.contains('Export Game') // can not run tests involving file dialog at the moment
		cy.contains('Unload Game').click()

		cy.contains('New Game')
	})

	it('can navigate between normal and property modes using keyboard', () => {
		cy.contains('Normal')

		cy.input('p')
        cy.contains('Property')

		cy.input('n')
        cy.contains('Normal')

		cy.input('p')
        cy.contains('Property')

        cy.input('Escape')
        cy.contains('Normal')
	})

	it('can manage new game file using keyboard', () => {
		cy.contains('Normal')
		cy.contains('New Game')

		cy.input('p')
		cy.input('n')

		cy.contains('Export Game') // can not run tests involving file dialog at the moment
		cy.contains('Unload Game')

		cy.input('p')
		cy.input('g')

		cy.contains('New Game')
	})

	it('can load game', () => {
		cy.loadGame()
	})
})
