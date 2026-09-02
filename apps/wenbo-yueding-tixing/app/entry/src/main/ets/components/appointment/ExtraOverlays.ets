import { AppointmentItem, WeekDigest } from '../../models/AppointmentModels'
import { RhythmOverlay } from './RhythmOverlay'
import { WeeklyReviewOverlay } from './WeeklyReviewOverlay'
import { PostponeOverlay } from './PostponeOverlay'

@Component
export struct ExtraOverlays {
  @Prop showRhythm: boolean = false
  @Prop showReview: boolean = false
  @Prop showPostpone: boolean = false
  @Prop digest: WeekDigest = new WeekDigest()
  @Prop postponeItem: AppointmentItem = new AppointmentItem()
  onCloseRhythm: () => void = () => {}
  onApplyRhythm: (category: string) => void = () => {}
  onCloseReview: () => void = () => {}
  onExport: () => void = () => {}
  onHandleMissed: () => void = () => {}
  onClosePostpone: () => void = () => {}
  onPickPostpone: (minutes: number) => void = () => {}

  build() {
    Stack() {
      if (this.showRhythm) {
        RhythmOverlay({
          onClose: (): void => { this.onCloseRhythm() },
          onApply: (category: string): void => { this.onApplyRhythm(category) }
        })
          .width('100%')
          .height('100%')
      }
      if (this.showReview) {
        WeeklyReviewOverlay({
          digest: this.digest,
          onClose: (): void => { this.onCloseReview() },
          onExport: (): void => { this.onExport() },
          onCreateMissed: (): void => { this.onHandleMissed() }
        })
          .width('100%')
          .height('100%')
      }
      if (this.showPostpone) {
        PostponeOverlay({
          item: this.postponeItem,
          onClose: (): void => { this.onClosePostpone() },
          onPick: (minutes: number): void => { this.onPickPostpone(minutes) }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
