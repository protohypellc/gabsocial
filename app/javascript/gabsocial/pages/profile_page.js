import React from 'react';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { fetchAccount, fetchAccountByUsername } from '../actions/accounts';
import { List as ImmutableList } from 'immutable';
import ImmutablePureComponent from 'react-immutable-pure-component';
import HeaderContainer from '../features/account_timeline/containers/header_container';
import { NavLink } from 'react-router-dom';
import WhoToFollowPanel from '../features/ui/components/who_to_follow_panel';
// import TrendsPanel from '../features/ui/components/trends_panel';
import LinkFooter from '../features/ui/components/link_footer';
import SignUpPanel from '../features/ui/components/sign_up_panel';
import ProfileInfoPanel from '../features/ui/components/profile_info_panel';

const emptyList = ImmutableList();

const mapStateToProps = (state, { params: { username }, withReplies = false }) => {
  const accounts = state.getIn(['accounts']);
  const accountFetchError = (state.getIn(['accounts', -1, 'username'], '').toLowerCase() == username.toLowerCase());

  let accountId = -1;
  let account = null;
  let accountUsername = username;
  if (accountFetchError) {
    accountId = null;
  }
  else {
    account = accounts.find(acct => username.toLowerCase() == acct.getIn(['acct'], '').toLowerCase());
    accountId = account ? account.getIn(['id'], null) : -1;
    accountUsername = account ? account.getIn(['acct'], '') : '';
  }

  //Children components fetch information

  return {
    account,
    accountId,
    accountUsername,
  };
};

export default @connect(mapStateToProps)
class ProfilePage extends ImmutablePureComponent {
  static propTypes = {
    account: ImmutablePropTypes.map,
    accountUsername: PropTypes.string.isRequired,
  };

  render () {
    const {children, accountId, account, accountUsername} = this.props;

    return (
      <div className='page'>
        <div className='page__top'>
          <HeaderContainer accountId={accountId} username={accountUsername}/>
        </div>

        <div className='page__columns'>
          <div className='columns-area__panels'>

            <div className='columns-area__panels__pane columns-area__panels__pane--left'>
              <div className='columns-area__panels__pane__inner'>
                <ProfileInfoPanel username={accountUsername} account={account} />
              </div>
            </div>

            <div className='columns-area__panels__main'>
              <div className='columns-area columns-area--mobile'>
                {children}
              </div>
            </div>

            <div className='columns-area__panels__pane columns-area__panels__pane--right'>
              <div className='columns-area__panels__pane__inner'>
                <SignUpPanel />
                <WhoToFollowPanel />
                {/* <TrendsPanel /> */}
                <LinkFooter />
              </div>
            </div>

          </div>
        </div>

      </div>
    )
  }
}
