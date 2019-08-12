import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { me } from '../../../initial_state';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Avatar from '../../../components/avatar';
import ImmutablePureComponent from 'react-immutable-pure-component';
import IconButton from 'gabsocial/components/icon_button';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

const mapStateToProps = state => {
  return {
    account: state.getIn(['accounts', me]),
  };
};

class UnauthorizedModal extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    onClose: PropTypes.func.isRequired,
  };

  onClickClose = () => {
    this.props.onClose('UNAUTHORIZED');
  };

  render () {
    const { intl, onClose, account } = this.props;

    return (
      <div className='modal-root__modal compose-modal unauthorized-modal'>
        <div className='compose-modal__header'>
          <h3 className='compose-modal__header__title'><FormattedMessage id='unauthorized_modal.title' defaultMessage='Sign up for Gab' /></h3>
          <IconButton className='compose-modal__close' title={intl.formatMessage(messages.close)} icon='times' onClick={this.onClickClose} size={20} />
        </div>
        <div className='compose-modal__content'>
          <div className='unauthorized-modal__content'>
            <span className='unauthorized-modal-content__text'>
              <FormattedMessage id='unauthorized_modal.text' defaultMessage='You need to be logged in to do that.' />
            </span>
            <a href='/auth/sign_up' className='unauthorized-modal-content__button button'>
              <FormattedMessage id='account.register' defaultMessage='Sign up' />
            </a>
          </div>
        </div>
        <div className='unauthorized-modal__footer'>
          <FormattedMessage id='unauthorized_modal.footer' defaultMessage='Already have an account? {login}.' values={{
            login: <a href='/auth/sign_in'><FormattedMessage id='account.login' defaultMessage='Log in' /></a>
          }} />
        </div>
      </div>
    );
  }
}

export default injectIntl(connect(mapStateToProps)(UnauthorizedModal));
