context('player', () => {
	beforeEach(() => {
		cy.visit('/')
	})

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
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)
		cy.contains('⏸').click()

		cy.contains('⏮').click()
		cy.contains('⏯')
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
	})

	it('can go to the end of the song', () => {
		cy.contains('⏭').click()
		cy.contains('⏯')
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
	})

	it('can seek backward / forward using button', () => {
		cy.contains('⏮').click()

		cy.contains('⏩').click()
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)
		cy.contains('⏪').click()
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
	})

	it('can seek backward / forward using keyboard', () => {
		cy.contains('⏮').click()

		cy.input('ArrowRight')
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)
		cy.input('ArrowLeft')
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
	})

	it('can not overflow by seeking to far backward', () => {
		cy.contains('⏮').click()

		cy.input('ArrowLeft')
		cy.input('ArrowLeft')
		cy.input('ArrowLeft')
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.eq', '0')
		cy.input('ArrowRight')
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gt', 0)
	})

	it('can not overflow by seeking to far forward', () => {
		cy.contains('⏮').click()

		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.input('ArrowRight')
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.gte', '10')
		cy.input('ArrowLeft')
		cy.get('nav input[type="range"]').should('have.prop', 'value').and('be.lt', 10)
	})

})
