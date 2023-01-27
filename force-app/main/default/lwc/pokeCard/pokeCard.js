import { LightningElement, api } from 'lwc';

export default class PokeCard extends LightningElement {
	@api pokemon;
    handleOpenRecordClick() {
        const selectEvent = new CustomEvent('pokemonview', {
            detail: this.pokemon.Id
        });
        this.dispatchEvent(selectEvent);
    }
}