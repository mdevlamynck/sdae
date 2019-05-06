cy.input = function(key) {
	cy.document().then(d => {
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

context('SDAE', () => {
	beforeEach(() => {
		cy.visit('/')
	})

	it('can manage game file using keyboard', function() {
		cy.contains('New Game')
		cy.input('n')

		cy.contains('Export Game') // can not run tests involving file dialog at the moment
		cy.contains('Unload Game')
		cy.input('g')

		cy.contains('New Game')
	})

	it('can manage game file using buttons', function() {
		cy.contains('New Game').click()

		cy.contains('Export Game') // can not run tests involving file dialog at the moment
		cy.contains('Unload Game').click()

		cy.contains('New Game')
	})

	it('can edit hits using keyboard', function() {
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

	it('can edit hits using buttons', function() {
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
