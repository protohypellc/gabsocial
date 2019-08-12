import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import AvatarOverlay from '../../../components/avatar_overlay';
import DisplayName from '../../../components/display_name';
import Icon from 'gabsocial/components/icon';
import { NavLink } from 'react-router-dom';

export default class MovedNote extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    from: ImmutablePropTypes.map.isRequired,
    to: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const { from, to } = this.props;
    const displayNameHtml = { __html: from.get('display_name_html') };

    return (
      <div className='account__moved-note'>
        <div className='account__moved-note__message'>
          <div className='account__moved-note__icon-wrapper'><Icon id='suitcase' className='account__moved-note__icon' fixedWidth /></div>
          <FormattedMessage id='account.moved_to' defaultMessage='{name} has moved to:' values={{ name: <bdi><strong dangerouslySetInnerHTML={displayNameHtml} /></bdi> }} />
        </div>

        <NavLink to={`/${this.props.to.get('acct')}`} className='detailed-status__display-name'>
          <div className='detailed-status__display-avatar'><AvatarOverlay account={to} friend={from} /></div>
          <DisplayName account={to} />
        </NavLink>
      </div>
    );
  }

}
