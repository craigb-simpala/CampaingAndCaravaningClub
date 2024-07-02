/**
 * Created by admin on 25.12.2022.
 */

import {api, LightningElement} from 'lwc';

export default class CmpToast extends LightningElement {
    title = '';
    message = '';
    variant = '';
    autoClose = false;
    autoCloseTime = 3000;
    htmlUnescapedMessage = false;

    isVisible = false;

    closeText = 'close';

    get mainDivClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.variant;
    }

    get messageDivClass() {
        return 'slds-icon_container slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top slds-icon-utility-' + this.variant;
    }

    get iconName() {
        return 'utility:' + this.variant;
    }

    @api
    showToast(title, message, variant, autoClose = true, autoCloseTime, htmlUnescapedMessage) {
        this.title = title;
        this.message = message;
        this.variant = variant;
        this.autoClose = autoClose;
        this.autoCloseTime = autoCloseTime ? autoCloseTime : 3000;
        this.htmlUnescapedMessage = htmlUnescapedMessage ? htmlUnescapedMessage : false;

        this.isVisible = true;
        if (this.autoClose) {
            setTimeout(() => this.closeModal(), this.autoCloseTime);
        }
    }

    closeModal() {
        this.isVisible = false;

    }
}