context('editor', () => {
	beforeEach(() => {
		cy.visit('/')
		cy.loadSong()
	})

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

	it('using the editor creates an input when none is active', () => {
		cy.contains('⏸').click()

		cy.get('[data-cy="hit 1"]').should('not.exist')

		cy.input('KeyF')

		cy.get('[data-cy="hit 1"]').should('have.prop', 'active', true)
	})

	it('when song is playing, using the editor creates inputs over time', () => {
		cy.contains('⏮').click()
		cy.get('[data-cy="hit 1"]').should('not.exist')

		cy.input('KeyF')
		cy.get('[data-cy="hit 1"]').should('have.prop', 'active', true)

		cy.contains('⏯').click()
		cy.wait(200)
		cy.contains('⏸').click()

		cy.input('KeyF')
		cy.get('[data-cy="hit 2"]').should('have.prop', 'active', true)
		cy.get('[data-cy="hit 1"]').should('have.prop', 'active', false)
	})

	it('adding a hit then removing it ends up with an empty input', () => {
		cy.get('[data-cy="hit 1"]').should('not.exist')

		cy.input('KeyF')
		cy.get('[data-cy="hit 1"]').contains('(empty)').should('not.exist')

		cy.input('KeyF')
		cy.get('[data-cy="hit 1"]').contains('(empty)')
	})

	it('clicking on input seeks to the input pos', () => {
		cy.contains('⏮').click()

		cy.input('KeyF')

		cy.contains('⏯').click()
		cy.wait(200)
		cy.contains('⏸').click()

		cy.input('KeyD')

		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)
		cy.get('[data-cy="hit 1"]').should('have.prop', 'active', false)
		cy.get('[data-cy="hit 2"]').should('have.prop', 'active', true)

		cy.get('[data-cy="hit 1"]').click()

		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
		cy.get('[data-cy="hit 1"]').should('have.prop', 'active', true)
		cy.get('[data-cy="hit 2"]').should('have.prop', 'active', false)
	})

	describe('with inputs', () => {
		beforeEach(() => {
			cy.contains('⏮').click()

			cy.contains('⏯').click()
			cy.wait(100)
			cy.contains('⏸').click()

			cy.input('KeyF')

			cy.contains('⏯').click()
			cy.wait(200)
			cy.contains('⏸').click()

			cy.input('KeyD')
		})

		it('clicking the cross beside it deletes the input', () => {
			cy.get('[data-cy="hit 1"]')
			cy.get('[data-cy="hit 2"]')

			cy.get('[data-cy="hit 2"]').contains('❌').click()

			cy.get('[data-cy="hit 1"]')
			cy.get('[data-cy="hit 2"]').should('not.exist')
		})

		it('up seeks to the previous input', () => {
			cy.contains('⏯').click()
			cy.wait(300)
			cy.contains('⏸').click()

			cy.get('[data-cy="hit 1"]').should('have.prop', 'active', false)
			cy.get('[data-cy="hit 2"]').should('have.prop', 'active', false)
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

			cy.input('ArrowUp')

			cy.get('[data-cy="hit 1"]').should('have.prop', 'active', false)
			cy.get('[data-cy="hit 2"]').should('have.prop', 'active', true)
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

			cy.input('ArrowUp')

			cy.get('[data-cy="hit 1"]').should('have.prop', 'active', true)
			cy.get('[data-cy="hit 2"]').should('have.prop', 'active', false)
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

			cy.input('ArrowUp')

			cy.get('[data-cy="hit 1"]').should('have.prop', 'active', false)
			cy.get('[data-cy="hit 2"]').should('have.prop', 'active', false)
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
		})

		it('down seeks to the next input', () => {
			cy.contains('⏮').click()

			cy.get('[data-cy="hit 1"]').should('have.prop', 'active', false)
			cy.get('[data-cy="hit 2"]').should('have.prop', 'active', false)
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')

			cy.input('ArrowDown')

			cy.get('[data-cy="hit 1"]').should('have.prop', 'active', true)
			cy.get('[data-cy="hit 2"]').should('have.prop', 'active', false)
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

			cy.input('ArrowDown')

			cy.get('[data-cy="hit 1"]').should('have.prop', 'active', false)
			cy.get('[data-cy="hit 2"]').should('have.prop', 'active', true)
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)

			cy.input('ArrowDown')

			cy.get('[data-cy="hit 1"]').should('have.prop', 'active', false)
			cy.get('[data-cy="hit 2"]').should('have.prop', 'active', false)
			cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)
		})
	})
})
