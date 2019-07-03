const withStages = () => {
	cy.visit('/')
	cy.loadGame()
	cy.contains('Duplicate Stage').click()
}

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

	describe('managing stages', () => {
		it('clicking on input seeks to the input pos', () => {
			withStages()

			cy.get('[data-cy="stage easy p1"]').should('have.prop', 'checked', false)
			cy.get('[data-cy="stage easy p2"]').should('have.prop', 'checked', true)

			cy.get('[data-cy="stage easy p1"]').click()

			cy.get('[data-cy="stage easy p1"]').should('have.prop', 'checked', true)
			cy.get('[data-cy="stage easy p2"]').should('have.prop', 'checked', false)
		})

		it('can duplicate the current stage using buttons', () => {
			cy.loadGame()

			cy.contains('P1')
			cy.contains('P2').should('not.exist')

			cy.contains('Duplicate Stage').click()

			cy.contains('P1')
			cy.contains('P2')
		})

		it('can duplicate the current stage using keyboards', () => {
			cy.loadGame()

			cy.contains('P1')
			cy.contains('P2').should('not.exist')

			cy.input('p')
			cy.input('d')

			cy.contains('P1')
			cy.contains('P2')
		})

		it('the cross beside the input only appears on hover', () => {
            withStages()

            cy.get('[data-cy="stage easy p1"]').contains('❌').should('not.exist')
            cy.get('[data-cy="stage easy p2"]').contains('❌').should('not.exist')

            cy.get('[data-cy="stage easy p1"]').trigger('mouseenter')
            cy.get('[data-cy="stage easy p1"]').contains('❌')
            cy.get('[data-cy="stage easy p2"]').contains('❌').should('not.exist')

            cy.get('[data-cy="stage easy p1"]').trigger('mouseleave')
            cy.get('[data-cy="stage easy p1"]').contains('❌').should('not.exist')
            cy.get('[data-cy="stage easy p2"]').contains('❌').should('not.exist')
        })

        it('clicking the cross beside it deletes the input', () => {
            withStages()

            cy.get('[data-cy="stage easy p1"]')
            cy.get('[data-cy="stage easy p2"]')

            cy.get('[data-cy="stage easy p2"]').trigger('mouseenter')
            cy.get('[data-cy="stage easy p2"]').contains('❌').click()

            cy.get('[data-cy="stage easy p1"]')
            cy.get('[data-cy="stage easy p2"]').should('not.exist')
        })

        it('x deletes the current input', () => {
            withStages()

            cy.get('[data-cy="stage easy p2"]').click()
            cy.get('[data-cy="stage easy p2"]').should('have.prop', 'checked', true)

			cy.input('p')
            cy.input('x')

            cy.get('[data-cy="stage easy p2"]').should('not.exist')
        })
	})
})
