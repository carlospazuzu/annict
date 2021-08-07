import { Controller } from 'stimulus';

export default class extends Controller {
  static values = { workId: Number, episodeId: Number };

  episodeIdValue!: number;
  isNotSpoiler!: boolean;
  workIdValue!: number;

  initialize() {
    document.addEventListener('component-value-fetcher:spoiler-guard:fetched', (event: any) => {
      const {
        is_signed_in,
        hide_record_body,
        watched_anime_ids,
        anime_ids_in_library,
        tracked_episode_ids,
      } = event.detail;

      this.isNotSpoiler =
        !is_signed_in ||
        !hide_record_body ||
        !anime_ids_in_library.includes(this.workIdValue) ||
        (!this.episodeIdValue && watched_anime_ids.includes(this.workIdValue)) ||
        (this.episodeIdValue && tracked_episode_ids.includes(this.episodeIdValue));

      this.render();
    });
  }

  render() {
    if (this.isNotSpoiler) {
      this.element.classList.remove('is-spoiler');
    }
  }

  hide() {
    this.isNotSpoiler = true;
    this.render();
  }
}
