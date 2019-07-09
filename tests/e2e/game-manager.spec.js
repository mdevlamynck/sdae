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
        it('clicking on stage switches to the stage', () => {
            cy.loadGame()

            cy.get('[data-cy="stage easy p1"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="stage easy p2"]').should('have.prop', 'checked', false)

            cy.get('[data-cy="stage easy p2"]').click()

            cy.get('[data-cy="stage easy p1"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="stage easy p2"]').should('have.prop', 'checked', true)
        })

        it('can apply the inputs to all stages using buttons', () => {
            cy.loadGame()

            cy.get('[data-cy="stage easy p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage normal p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage normal p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage hard p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage hard p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage superhard p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage superhard p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage easy p1"]').click()
            cy.contains('Apply all Stages').click()

            cy.get('[data-cy="stage easy p2"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage normal p1"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage normal p2"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage hard p1"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage hard p2"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage superhard p1"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage superhard p2"]').click()
            cy.get('[data-cy^="hit"]')
        })

        it('can apply the inputs to all stages using keyboard', () => {
            cy.loadGame()

            cy.get('[data-cy="stage easy p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage normal p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage normal p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage hard p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage hard p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage superhard p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage superhard p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage easy p1"]').click()
            
            cy.input('p')
            cy.input('s')

            cy.get('[data-cy="stage easy p2"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage normal p1"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage normal p2"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage hard p1"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage hard p2"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage superhard p1"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage superhard p2"]').click()
            cy.get('[data-cy^="hit"]')
        })

        it('can apply the inputs to the other player using buttons', () => {
            cy.loadGame()

            cy.get('[data-cy="stage easy p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage easy p1"]').click()
            cy.contains('Apply other Player').click()

            cy.get('[data-cy="stage easy p2"]').click()
            cy.get('[data-cy^="hit"]')
        })

        it('can apply the inputs to the other player using keyboard', () => {
            cy.loadGame()

            cy.get('[data-cy="stage easy p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage normal p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage normal p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage hard p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage hard p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage superhard p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage superhard p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage easy p1"]').click()
            
            cy.input('p')
            cy.input('p')

            cy.get('[data-cy="stage easy p2"]').click()
            cy.get('[data-cy^="hit"]')

            cy.get('[data-cy="stage normal p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage normal p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage hard p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage hard p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage superhard p1"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')

            cy.get('[data-cy="stage superhard p2"]').click()
            cy.get('[data-cy^="hit"]').should('not.exist')
        })
    })
})
