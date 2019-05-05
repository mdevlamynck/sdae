context('Actions', () => {
	beforeEach(() => {
		cy.visit('/')
	})

	describe('SDAE', function() {
		it('can manage game file using buttons', function() {
			cy.contains('New Game').click()

			cy.contains('Export Game') // can not run tests involving file dialog at the moment
			cy.contains('Unload Game').click()

			cy.contains('New Game')
		})

		it('can edit hits', function() {
			cy.get('main').contains('f').parent().click().should('have.prop', 'checked', false)
			cy.get('main').contains('f').parent().click().should('have.prop', 'checked', true)
		})
	})
})
