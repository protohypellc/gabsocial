import React from 'react';
import { connect } from 'react-redux';
import { openModal } from '../../../actions/modal';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import DropdownMenuContainer from '../../../containers/dropdown_menu_container';
import { defineMessages, injectIntl } from 'react-intl';
import { meUsername } from 'gabsocial/initial_state';

const messages = defineMessages({
  profile: { id: 'account.profile', defaultMessage: 'Profile' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: { id: 'navigation_bar.domain_blocks', defaultMessage: 'Hidden domains' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  filters: { id: 'navigation_bar.filters', defaultMessage: 'Muted words' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  keyboard_shortcuts: { id: 'navigation_bar.keyboard_shortcuts', defaultMessage: 'Hotkeys' },
});

const mapDispatchToProps = (dispatch) => ({
  onOpenHotkeys() {
    dispatch(openModal('HOTKEYS'));
  },
});

class ActionBar extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    size: PropTypes.number,
  };

  handleHotkeyClick = () => {
    this.props.onOpenHotkeys();
  }

  render () {
    const { intl, onOpenHotkeys } = this.props;
    const size = this.props.size || 16;

    let menu = [];

    menu.push({ text: intl.formatMessage(messages.profile), to: `/${meUsername}` });
    menu.push(null);
    menu.push({ text: intl.formatMessage(messages.follow_requests), to: '/follow_requests' });
    menu.push({ text: intl.formatMessage(messages.mutes), to: '/mutes' });
    menu.push({ text: intl.formatMessage(messages.blocks), to: '/blocks' });
    menu.push({ text: intl.formatMessage(messages.domain_blocks), to: '/domain_blocks' });
    menu.push({ text: intl.formatMessage(messages.filters), to: '/filters' });
    menu.push(null);
    menu.push({ text: intl.formatMessage(messages.keyboard_shortcuts), action: this.handleHotkeyClick });
    menu.push({ text: intl.formatMessage(messages.preferences), href: '/settings/preferences' });
    menu.push({ text: intl.formatMessage(messages.logout), href: '/auth/sign_out', isLogout: true });

    return (
      <div className='compose__action-bar' style={{'marginTop':'-6px'}}>
        <div className='compose__action-bar-dropdown'>
          <DropdownMenuContainer items={menu} icon='chevron-down' size={size} direction='right' />
        </div>
      </div>
    );
  }
}

export default injectIntl(connect(null, mapDispatchToProps)(ActionBar));
