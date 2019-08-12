'use strict';

import classNames from 'classnames';
import React from 'react';
import { HotKeys } from 'react-hotkeys';
import { defineMessages, injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import { Switch, Redirect, withRouter } from 'react-router-dom';
import PropTypes from 'prop-types';
import NotificationsContainer from './containers/notifications_container';
import LoadingBarContainer from './containers/loading_bar_container';
import ModalContainer from './containers/modal_container';
import { isMobile } from '../../is_mobile';
import { debounce } from 'lodash';
import { uploadCompose, resetCompose } from '../../actions/compose';
import { expandHomeTimeline } from '../../actions/timelines';
import { expandNotifications } from '../../actions/notifications';
import { fetchFilters } from '../../actions/filters';
import { clearHeight } from '../../actions/height_cache';
import { openModal } from '../../actions/modal';
import { WrappedSwitch, WrappedRoute } from './util/react_router_helpers';
import UploadArea from './components/upload_area';
import TabsBar from './components/tabs_bar';
// import TrendsPanel from './components/trends_panel';
import WhoToFollowPanel from './components/who_to_follow_panel';
import LinkFooter from './components/link_footer';
import ProfilePage from 'gabsocial/pages/profile_page';
import GroupsPage from 'gabsocial/pages/groups_page';
import GroupPage from 'gabsocial/pages/group_page';
import SearchPage from 'gabsocial/pages/search_page';
import HomePage from 'gabsocial/pages/home_page';
import GroupSidebarPanel from '../groups/sidebar_panel';

import {
  Status,
  GettingStarted,
  CommunityTimeline,
  AccountTimeline,
  AccountGallery,
  HomeTimeline,
  Followers,
  Following,
  Reblogs,
  Favourites,
  DirectTimeline,
  HashtagTimeline,
  Notifications,
  FollowRequests,
  GenericNotFound,
  FavouritedStatuses,
  Blocks,
  DomainBlocks,
  Mutes,
  PinnedStatuses,
  Search,
  Explore,
  Groups,
  GroupTimeline,
  ListTimeline,
  Lists,
  GroupMembers,
  GroupRemovedAccounts,
  GroupCreate,
  GroupEdit,
} from './util/async-components';
import { me, meUsername } from '../../initial_state';
import { previewState as previewMediaState } from './components/media_modal';
import { previewState as previewVideoState } from './components/video_modal';

// Dummy import, to make sure that <Status /> ends up in the application bundle.
// Without this it ends up in ~8 very commonly used bundles.
import '../../components/status';
import { fetchGroups } from '../../actions/groups';

const messages = defineMessages({
  beforeUnload: { id: 'ui.beforeunload', defaultMessage: 'Your draft will be lost if you leave Gab Social.' },
  publish: { id: 'compose_form.publish', defaultMessage: 'Gab' },
});

const mapStateToProps = state => ({
  isComposing: state.getIn(['compose', 'is_composing']),
  hasComposingText: state.getIn(['compose', 'text']).trim().length !== 0,
  hasMediaAttachments: state.getIn(['compose', 'media_attachments']).size > 0,
  dropdownMenuIsOpen: state.getIn(['dropdown_menu', 'openId']) !== null,
});

const keyMap = {
  help: '?',
  new: 'n',
  search: 's',
  forceNew: 'option+n',
  focusColumn: ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
  reply: 'r',
  favourite: 'f',
  boost: 'b',
  mention: 'm',
  open: ['enter', 'o'],
  openProfile: 'p',
  moveDown: ['down', 'j'],
  moveUp: ['up', 'k'],
  back: 'backspace',
  goToHome: 'g h',
  goToNotifications: 'g n',
  goToStart: 'g s',
  goToFavourites: 'g f',
  goToPinned: 'g p',
  goToProfile: 'g u',
  goToBlocked: 'g b',
  goToMuted: 'g m',
  goToRequests: 'g r',
  toggleHidden: 'x',
  toggleSensitive: 'h',
};

const LAYOUT = {
  EMPTY: {
    LEFT: null,
    RIGHT: null,
  },
  DEFAULT: {
    LEFT: [
      <WhoToFollowPanel key='0' />,
      <LinkFooter key='1' />,
    ],
    RIGHT: [
      // <TrendsPanel />,
      <GroupSidebarPanel key='0' />
    ],
  },
  STATUS: {
    TOP: null,
    LEFT: null,
    RIGHT: [
      <GroupSidebarPanel key='0' />,
      <WhoToFollowPanel key='1' />,
      // <TrendsPanel />,
      <LinkFooter key='2' />,
    ],
  },
};

const shouldHideFAB = path => path.match(/^\/posts\/|^\/search|^\/getting-started/);

class SwitchingColumnsArea extends React.PureComponent {

  static propTypes = {
    children: PropTypes.node,
    location: PropTypes.object,
    onLayoutChange: PropTypes.func.isRequired,
  };

  state = {
    mobile: isMobile(window.innerWidth),
  };

  componentWillMount () {
    window.addEventListener('resize', this.handleResize, { passive: true });
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.handleResize);
  }

  handleResize = debounce(() => {
    // The cached heights are no longer accurate, invalidate
    this.props.onLayoutChange();

    this.setState({ mobile: isMobile(window.innerWidth) });
  }, 500, {
    trailing: true,
  });

  setRef = c => {
    this.node = c.getWrappedInstance();
  }

  render () {
    const { children, account } = this.props;
    const { mobile } = this.state;

    return (
      <Switch>
        <Redirect from='/' to='/home' exact />
        <WrappedRoute path='/home' exact page={HomePage} component={HomeTimeline} content={children} />
        <WrappedRoute path='/timeline/all' exact page={HomePage} component={CommunityTimeline} content={children} />

        <WrappedRoute path='/groups' exact page={GroupsPage} component={Groups} content={children} componentParams={{ activeTab: 'featured' }} />
        <WrappedRoute path='/groups/create' page={GroupsPage} component={Groups} content={children} componentParams={{ showCreateForm: true, activeTab: 'featured' }} />
        <WrappedRoute path='/groups/browse/member' page={GroupsPage} component={Groups} content={children} componentParams={{ activeTab: 'member' }} />
        <WrappedRoute path='/groups/browse/admin' page={GroupsPage} component={Groups} content={children} componentParams={{ activeTab: 'admin' }} />
        <WrappedRoute path='/groups/:id/members' page={GroupPage} component={GroupMembers} content={children} />
        <WrappedRoute path='/groups/:id/removed_accounts' page={GroupPage} component={GroupRemovedAccounts} content={children} />
        <WrappedRoute path='/groups/:id/edit' page={GroupPage} component={GroupEdit} content={children} />
        <WrappedRoute path='/groups/:id' page={GroupPage} component={GroupTimeline} content={children} />

        <WrappedRoute path='/tags/:id' component={HashtagTimeline} content={children} />

        <WrappedRoute path='/lists' layout={LAYOUT.DEFAULT} component={Lists} content={children} />
        <WrappedRoute path='/list/:id' page={HomePage} component={ListTimeline} content={children} />

        <WrappedRoute path='/notifications' layout={LAYOUT.DEFAULT} component={Notifications} content={children} />

        <WrappedRoute path='/search' publicRoute page={SearchPage} component={Search} content={children} />

        <WrappedRoute path='/follow_requests' layout={LAYOUT.DEFAULT} component={FollowRequests} content={children} />
        <WrappedRoute path='/blocks' layout={LAYOUT.DEFAULT} component={Blocks} content={children} />
        <WrappedRoute path='/domain_blocks' layout={LAYOUT.DEFAULT} component={DomainBlocks} content={children} />
        <WrappedRoute path='/mutes' layout={LAYOUT.DEFAULT} component={Mutes} content={children} />

        <Redirect     from='/@:username' to='/:username' exact />
        <WrappedRoute path='/:username' publicRoute exact component={AccountTimeline} page={ProfilePage} content={children} />

        <Redirect     from='/@:username/with_replies' to='/:username/with_replies' />
        <WrappedRoute path='/:username/with_replies' component={AccountTimeline} page={ProfilePage} content={children} componentParams={{ withReplies: true }} />

        <Redirect     from='/@:username/followers' to='/:username/followers' />
        <WrappedRoute path='/:username/followers' component={Followers} page={ProfilePage} content={children} />

        <Redirect     from='/@:username/following' to='/:username/following' />
        <WrappedRoute path='/:username/following' component={Following} page={ProfilePage} content={children} />

        <Redirect     from='/@:username/media' to='/:username/media' />
        <WrappedRoute path='/:username/media' component={AccountGallery} page={ProfilePage} content={children} />

        <Redirect     from='/@:username/tagged/:tag' to='/:username/tagged/:tag' exact />
        <WrappedRoute path='/:username/tagged/:tag' exact component={AccountTimeline} page={ProfilePage} content={children} />

        <Redirect     from='/@:username/favorites' to='/:username/favorites' />
        <WrappedRoute path='/:username/favorites' component={FavouritedStatuses} page={ProfilePage} content={children}  />

        <Redirect     from='/@:username/pins' to='/:username/pins' />
        <WrappedRoute path='/:username/pins' component={PinnedStatuses} page={ProfilePage} content={children} />

        <Redirect     from='/@:username/posts/:statusId' to='/:username/posts/:statusId' exact />
        <WrappedRoute path='/:username/posts/:statusId' publicRoute exact layout={LAYOUT.STATUS} component={Status} content={children} />

        <Redirect     from='/@:username/posts/:statusId/reblogs' to='/:username/posts/:statusId/reblogs' />
        <WrappedRoute path='/:username/posts/:statusId/reblogs' layout={LAYOUT.STATUS} component={Reblogs} content={children} />

        <WrappedRoute layout={LAYOUT.EMPTY} component={GenericNotFound} content={children} />
      </Switch>
    );
  }
}

export default @connect(mapStateToProps)
@injectIntl
@withRouter
class UI extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    children: PropTypes.node,
    isComposing: PropTypes.bool,
    hasComposingText: PropTypes.bool,
    hasMediaAttachments: PropTypes.bool,
    location: PropTypes.object,
    intl: PropTypes.object.isRequired,
    dropdownMenuIsOpen: PropTypes.bool,
  };

  state = {
    draggingOver: false,
  };

  handleBeforeUnload = (e) => {
    const { intl, isComposing, hasComposingText, hasMediaAttachments } = this.props;

    if (isComposing && (hasComposingText || hasMediaAttachments)) {
      // Setting returnValue to any string causes confirmation dialog.
      // Many browsers no longer display this text to users,
      // but we set user-friendly message for other browsers, e.g. Edge.
      e.returnValue = intl.formatMessage(messages.beforeUnload);
    }
  }

  handleLayoutChange = () => {
    // The cached heights are no longer accurate, invalidate
    this.props.dispatch(clearHeight());
  }

  handleDragEnter = (e) => {
    e.preventDefault();

    if (!this.dragTargets) {
      this.dragTargets = [];
    }

    if (this.dragTargets.indexOf(e.target) === -1) {
      this.dragTargets.push(e.target);
    }

    if (e.dataTransfer && Array.from(e.dataTransfer.types).includes('Files')) {
      this.setState({ draggingOver: true });
    }
  }

  handleDragOver = (e) => {
    if (this.dataTransferIsText(e.dataTransfer)) return false;
    e.preventDefault();
    e.stopPropagation();

    try {
      e.dataTransfer.dropEffect = 'copy';
    } catch (err) {

    }

    return false;
  }

  handleDrop = (e) => {
    if (!me) return;

    if (this.dataTransferIsText(e.dataTransfer)) return;
    e.preventDefault();

    this.setState({ draggingOver: false });
    this.dragTargets = [];

    if (e.dataTransfer && e.dataTransfer.files.length >= 1) {
      this.props.dispatch(uploadCompose(e.dataTransfer.files));
    }
  }

  handleDragLeave = (e) => {
    e.preventDefault();
    e.stopPropagation();

    this.dragTargets = this.dragTargets.filter(el => el !== e.target && this.node.contains(el));

    if (this.dragTargets.length > 0) {
      return;
    }

    this.setState({ draggingOver: false });
  }

  dataTransferIsText = (dataTransfer) => {
    return (dataTransfer && Array.from(dataTransfer.types).includes('text/plain') && dataTransfer.items.length === 1);
  }

  closeUploadModal = () => {
    this.setState({ draggingOver: false });
  }

  handleServiceWorkerPostMessage = ({ data }) => {
    if (data.type === 'navigate') {
      this.context.router.history.push(data.path);
    } else {
      console.warn('Unknown message type:', data.type);
    }
  }

  componentWillMount () {
    window.addEventListener('beforeunload', this.handleBeforeUnload, false);

    document.addEventListener('dragenter', this.handleDragEnter, false);
    document.addEventListener('dragover', this.handleDragOver, false);
    document.addEventListener('drop', this.handleDrop, false);
    document.addEventListener('dragleave', this.handleDragLeave, false);
    document.addEventListener('dragend', this.handleDragEnd, false);

    if ('serviceWorker' in  navigator) {
      navigator.serviceWorker.addEventListener('message', this.handleServiceWorkerPostMessage);
    }

    if (typeof window.Notification !== 'undefined' && Notification.permission === 'default') {
      window.setTimeout(() => Notification.requestPermission(), 120 * 1000);
    }

    if (me) {
      this.props.dispatch(expandHomeTimeline());
      this.props.dispatch(expandNotifications());
      this.props.dispatch(fetchGroups('member'));

      setTimeout(() => this.props.dispatch(fetchFilters()), 500);
    }
  }

  componentDidMount () {
    if (!me) return;
    this.hotkeys.__mousetrap__.stopCallback = (e, element) => {
      return ['TEXTAREA', 'SELECT', 'INPUT'].includes(element.tagName);
    };
  }

  componentWillUnmount () {
    window.removeEventListener('beforeunload', this.handleBeforeUnload);
    document.removeEventListener('dragenter', this.handleDragEnter);
    document.removeEventListener('dragover', this.handleDragOver);
    document.removeEventListener('drop', this.handleDrop);
    document.removeEventListener('dragleave', this.handleDragLeave);
    document.removeEventListener('dragend', this.handleDragEnd);
  }

  setRef = c => {
    this.node = c;
  }

  handleHotkeyNew = e => {
    e.preventDefault();

    const element = this.node.querySelector('.compose-form__autosuggest-wrapper textarea');

    if (element) {
      element.focus();
    }
  }

  handleHotkeySearch = e => {
    e.preventDefault();

    const element = this.node.querySelector('.search__input');

    if (element) {
      element.focus();
    }
  }

  handleHotkeyForceNew = e => {
    this.handleHotkeyNew(e);
    this.props.dispatch(resetCompose());
  }

  handleHotkeyFocusColumn = e => {
    const index  = (e.key * 1) + 1; // First child is drawer, skip that
    const column = this.node.querySelector(`.column:nth-child(${index})`);
    if (!column) return;
    const container = column.querySelector('.scrollable');

    if (container) {
      const status = container.querySelector('.focusable');

      if (status) {
        if (container.scrollTop > status.offsetTop) {
          status.scrollIntoView(true);
        }
        status.focus();
      }
    }
  }

  handleHotkeyBack = () => {
    if (window.history && window.history.length === 1) {
      this.context.router.history.push('/home'); // homehack
    } else {
      this.context.router.history.goBack();
    }
  }

  setHotkeysRef = c => {
    this.hotkeys = c;
  }

  handleHotkeyToggleHelp = () => {
    this.props.dispatch(openModal("HOTKEYS"));
  }

  handleHotkeyGoToHome = () => {
    this.context.router.history.push('/home');
  }

  handleHotkeyGoToNotifications = () => {
    this.context.router.history.push('/notifications');
  }

  handleHotkeyGoToStart = () => {
    this.context.router.history.push('/getting-started');
  }

  handleHotkeyGoToFavourites = () => {
    this.context.router.history.push(`/${meUsername}/favorites`);
  }

  handleHotkeyGoToPinned = () => {
    this.context.router.history.push(`/${meUsername}/pins`);
  }

  handleHotkeyGoToProfile = () => {
    this.context.router.history.push(`/${meUsername}`);
  }

  handleHotkeyGoToBlocked = () => {
    this.context.router.history.push('/blocks');
  }

  handleHotkeyGoToMuted = () => {
    this.context.router.history.push('/mutes');
  }

  handleHotkeyGoToRequests = () => {
    this.context.router.history.push('/follow_requests');
  }

  handleOpenComposeModal = () => {
    this.props.dispatch(openModal("COMPOSE"));
  }

  render () {
    const { draggingOver } = this.state;
    const { intl, children, isComposing, location, dropdownMenuIsOpen } = this.props;

    const handlers = me ? {
      help: this.handleHotkeyToggleHelp,
      new: this.handleHotkeyNew,
      search: this.handleHotkeySearch,
      forceNew: this.handleHotkeyForceNew,
      focusColumn: this.handleHotkeyFocusColumn,
      back: this.handleHotkeyBack,
      goToHome: this.handleHotkeyGoToHome,
      goToNotifications: this.handleHotkeyGoToNotifications,
      goToStart: this.handleHotkeyGoToStart,
      goToFavourites: this.handleHotkeyGoToFavourites,
      goToPinned: this.handleHotkeyGoToPinned,
      goToProfile: this.handleHotkeyGoToProfile,
      goToBlocked: this.handleHotkeyGoToBlocked,
      goToMuted: this.handleHotkeyGoToMuted,
      goToRequests: this.handleHotkeyGoToRequests,
    } : {};

    const floatingActionButton = shouldHideFAB(this.context.router.history.location.pathname) ? null : <button key='floating-action-button' onClick={this.handleOpenComposeModal} className='floating-action-button' aria-label={intl.formatMessage(messages.publish)}></button>;

    return (
      <HotKeys keyMap={keyMap} handlers={handlers} ref={this.setHotkeysRef} attach={window} focused>
        <div className={classNames('ui', { 'is-composing': isComposing })} ref={this.setRef} style={{ pointerEvents: dropdownMenuIsOpen ? 'none' : null }}>
          <TabsBar />
          <SwitchingColumnsArea location={location} onLayoutChange={this.handleLayoutChange}>
            {children}
          </SwitchingColumnsArea>

          {me && floatingActionButton}

          <NotificationsContainer />
          <LoadingBarContainer className='loading-bar' />
          <ModalContainer />
          <UploadArea active={draggingOver} onClose={this.closeUploadModal} />
        </div>
      </HotKeys>
    );
  }

}
