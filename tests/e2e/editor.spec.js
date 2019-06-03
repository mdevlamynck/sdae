const withInputsStartingAtZero = () => {
    cy.contains('⏮').click()

    cy.input('KeyF')

    cy.contains('⏯').click()
    cy.wait(150)
    cy.contains('⏸').click()

    cy.input('KeyD')
}

const withInputs = () => {
    cy.contains('⏮').click()

    cy.contains('⏯').click()
    cy.wait(50)
    cy.contains('⏸').click()

    cy.input('KeyF')

    cy.contains('⏯').click()
    cy.wait(150)
    cy.contains('⏸').click()

    cy.input('KeyD')
}

context('editor', () => {
    beforeEach(() => {
        cy.visit('/')
        cy.loadSong()
        cy.newGame()
    })

    describe('editing inputs', () => {
        it('can edit hits using buttons', () => {
            cy.contains('⏸').click()

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

        it('can edit hits using keyboard', () => {
            cy.contains('⏸').click()

            cy.input('KeyF')
            cy.get('main').contains('f').parent().should('have.prop', 'checked', true)
            cy.input('KeyD')
            cy.get('main').contains('d').parent().should('have.prop', 'checked', true)
            cy.input('KeyS')
            cy.get('main').contains('s').parent().should('have.prop', 'checked', true)
            cy.input('KeyJ')
            cy.get('main').contains('j').parent().should('have.prop', 'checked', true)
            cy.input('KeyK')
            cy.get('main').contains('k').parent().should('have.prop', 'checked', true)
            cy.input('KeyL')
            cy.get('main').contains('l').parent().should('have.prop', 'checked', true)

            cy.input('KeyF')
            cy.get('main').contains('f').parent().should('have.prop', 'checked', false)
            cy.input('KeyD')
            cy.get('main').contains('d').parent().should('have.prop', 'checked', false)
            cy.input('KeyS')
            cy.get('main').contains('s').parent().should('have.prop', 'checked', false)
            cy.input('KeyJ')
            cy.get('main').contains('j').parent().should('have.prop', 'checked', false)
            cy.input('KeyK')
            cy.get('main').contains('k').parent().should('have.prop', 'checked', false)
            cy.input('KeyL')
            cy.get('main').contains('l').parent().should('have.prop', 'checked', false)
        })

        it('can change kind of input using buttons', () => {
            cy.contains('⏮').click()

            cy.get('[data-cy="regular"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', false)

            cy.input('KeyF')

            cy.get('[data-cy="regular"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', false)

            cy.get('[data-cy="long"]').click()
            cy.get('[data-cy="regular"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', false)

            cy.get('[data-cy="pose"]').click()
            cy.get('[data-cy="regular"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', true)

            cy.get('[data-cy="regular"]').click()
            cy.get('[data-cy="regular"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', false)
        })

        it('can change kind of input using keyboard', () => {
            cy.contains('⏮').click()

            cy.get('[data-cy="regular"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', false)

            cy.input('KeyF')

            cy.get('[data-cy="regular"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', false)

            cy.input('KeyI')
            cy.get('[data-cy="regular"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', false)

            cy.input('KeyO')
            cy.get('[data-cy="regular"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', true)

            cy.input('KeyU')
            cy.get('[data-cy="regular"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', false)
        })

        it('using the editor creates an input when none is checked in regular mode by default', () => {
            cy.contains('⏸').click()

            cy.get('[data-cy="hit 1"]').should('not.exist')

            cy.input('KeyF')

            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="regular"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="long"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="pose"]').should('have.prop', 'checked', false)
        })

        it('when song is playing, using the editor creates inputs over time', () => {
            cy.contains('⏮').click()
            cy.get('[data-cy="hit 1"]').should('not.exist')

            cy.input('KeyF')
            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', true)

            cy.contains('⏯').click()
            cy.wait(200)
            cy.contains('⏸').click()

            cy.input('KeyF')
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', false)
        })

        it('adding a hit then removing it ends up with an empty input', () => {
            cy.contains('⏮').click()

            cy.get('[data-cy="hit 1"]').should('not.exist')

            cy.input('KeyF')
            cy.get('[data-cy="hit 1"]').contains('(empty)').should('not.exist')

            cy.input('KeyF')
            cy.get('[data-cy="hit 1"]').contains('(empty)')
        })
    });

    describe('navigating inputs', () => {
        it('clicking on input seeks to the input pos', () => {
            withInputsStartingAtZero()

            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)
            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', true)

            cy.get('[data-cy="hit 1"]').click()

            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', false)
        })

        it('up seeks to the previous input', () => {
            withInputs()

            cy.contains('⏯').click()
            cy.wait(150)
            cy.contains('⏸').click()

            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', false)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

            cy.input('ArrowUp')

            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', true)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

            cy.input('ArrowUp')

            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', false)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

            cy.input('ArrowUp')

            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', false)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
        })

        it('down seeks to the next input', () => {
            withInputs()
            cy.contains('⏮').click()

            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', false)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')

            cy.input('ArrowDown')

            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', true)
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', false)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

            cy.input('ArrowDown')

            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', true)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

            cy.input('ArrowDown')

            cy.get('[data-cy="hit 1"]').should('have.prop', 'checked', false)
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', false)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)
        })

        it('when playing the input list scrolls to keep the current input visible', () => {
            cy.loadGame()

            cy.get('#input129').should('not.be.visible')
            cy.get('#input129').should('be.visible').should('have.prop', 'checked', false)
            cy.get('#input129').should('be.visible').should('have.prop', 'checked', true)
            cy.get('#input129').should('be.visible').should('have.prop', 'checked', false)
            cy.get('#input129').should('not.be.visible')
        })
    })

    describe('managing inputs', () => {
        it('the cross beside the input only appears on hover', () => {
            withInputs()

            cy.get('[data-cy="hit 1"]').contains('❌').should('not.exist')
            cy.get('[data-cy="hit 2"]').contains('❌').should('not.exist')

            cy.get('[data-cy="hit 1"]').trigger('mouseenter')
            cy.get('[data-cy="hit 1"]').contains('❌')
            cy.get('[data-cy="hit 2"]').contains('❌').should('not.exist')

            cy.get('[data-cy="hit 1"]').trigger('mouseleave')
            cy.get('[data-cy="hit 1"]').contains('❌').should('not.exist')
            cy.get('[data-cy="hit 2"]').contains('❌').should('not.exist')
        })

        it('clicking the cross beside it deletes the input', () => {
            withInputs()

            cy.get('[data-cy="hit 1"]')
            cy.get('[data-cy="hit 2"]')

            cy.get('[data-cy="hit 2"]').trigger('mouseenter')
            cy.get('[data-cy="hit 2"]').contains('❌').click()

            cy.get('[data-cy="hit 1"]')
            cy.get('[data-cy="hit 2"]').should('not.exist')
        })

        it('x deletes the current input', () => {
            withInputs()

            cy.get('[data-cy="hit 2"]').click()
            cy.get('[data-cy="hit 2"]').should('have.prop', 'checked', true)

            cy.input('x')

            cy.get('[data-cy="hit 2"]').should('not.exist')
        })
    })

    describe('history', () => {
        it('z undoes the last change, y redoes the last undo', () => {
            withInputsStartingAtZero()

            cy.get('[data-cy="hit 1"]')
            cy.get('[data-cy="hit 2"]')
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

            cy.input('z')

            cy.get('[data-cy="hit 1"]')
            cy.get('[data-cy="hit 2"]').should('not.exist')
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')

            cy.input('z')

            cy.get('[data-cy="hit 1"]').should('not.exist')
            cy.get('[data-cy="hit 2"]').should('not.exist')
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')

            cy.input('y')

            cy.get('[data-cy="hit 1"]')
            cy.get('[data-cy="hit 2"]').should('not.exist')
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')

            cy.input('y')

            cy.get('[data-cy="hit 1"]')
            cy.get('[data-cy="hit 2"]')
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)
        })

        it('making changes after undo loses the history (prevents redo)', () => {
            withInputsStartingAtZero()

            cy.input('z')
            cy.input('z')

            cy.get('[data-cy="hit 1"]').should('not.exist')
            cy.get('[data-cy="hit 2"]').should('not.exist')
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')

            cy.input('f')
            cy.input('y')

            cy.get('[data-cy="hit 1"]').should('not.exist')
            cy.get('[data-cy="hit 2"]').should('not.exist')
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
        })

        it('an alternate history can still be traversed', () => {
            withInputsStartingAtZero()

            cy.input('z')
            cy.input('KeyD')
            cy.input('z')
            cy.input('z')

            cy.get('[data-cy="hit 1"]').should('not.exist')
            cy.get('main').contains('f').parent().should('have.prop', 'checked', false)
            cy.get('main').contains('d').parent().should('have.prop', 'checked', false)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')

            cy.input('y')

            cy.get('[data-cy="hit 1"]')
            cy.get('main').contains('f').parent().should('have.prop', 'checked', true)
            cy.get('main').contains('d').parent().should('have.prop', 'checked', false)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')

            cy.input('y')

            cy.get('[data-cy="hit 1"]')
            cy.get('main').contains('f').parent().should('have.prop', 'checked', true)
            cy.get('main').contains('d').parent().should('have.prop', 'checked', true)
            cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
        })

        it('going beyond history is noop', () => {
            withInputsStartingAtZero()

            cy.input('z')
            cy.input('z')
            cy.input('z')

            cy.get('[data-cy="hit 1"]').should('not.exist')
        })
    })
})
