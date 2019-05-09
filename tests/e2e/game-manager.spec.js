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

	it('can manage new game file using keyboard', () => {
		cy.contains('New Game')
		cy.input('n')

		cy.contains('Export Game') // can not run tests involving file dialog at the moment
		cy.contains('Unload Game')
		cy.input('g')

		cy.contains('New Game')
	})

	it('can load game', () => {
		cy.loadGame()
	})

})
