import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { SportChallenge, ChallengeProgress, SportRecord } from '../../models/SportModels'
import { ChallengeStore } from '../../services/ChallengeStore'
import { SportStore } from '../../services/SportStore'
import { SportAnalytics } from '../../services/SportAnalytics'
import { SportDetailNav } from '../../services/SportDetailNav'
import { SportListCard } from '../sport/SportListCard'
import { SportModelClone } from '../../services/SportModelClone'

@Component
export struct ChallengeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop challengeId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: SportChallenge = new SportChallenge()
  @State progress: ChallengeProgress = new ChallengeProgress()
  @State related: SportRecord[] = []
  @State confirmDelete: boolean = false
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.load()
  }

  onRefreshTokenChange(): void {
    this.load()
  }

  private load(): void {
    const found = ChallengeStore.findById(this.challengeId)
    if (found !== null) {
      this.item = found
      this.progress = SportAnalytics.challengeProgress(found)
      this.related = this.relatedRecords(found)
    }
  }

  private relatedRecords(ch: SportChallenge): SportRecord[] {
    const out: SportRecord[] = []
    for (const r of SportStore.list()) {
      if (r.recordDate < ch.startDate || r.recordDate > ch.endDate) {
        continue
      }
      if (ch.sportType !== '全部' && r.sportType !== ch.sportType) {
        continue
      }
      if (out.length < 6) {
        out.push(r)
      }
    }
    return out
  }

  build() {
    DetailShell({
      title: '挑战详情',
      onClose: (): void => {
        SportDetailNav.close()
      },
      body: (): void => {
        this.BodyContent()
      },
      footer: (): void => {
        this.FooterActions()
      }
    })
  }

  @Builder
  BodyContent() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.ambient_data_bg'))
        .width('100%')
        .height(220)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column({ space: 0 })
        .width('100%')
        .height(220)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: Theme.heroScrim()
        })
      Column({ space: 8 }) {
        Text(this.item.status === 'done' ? '已完成赛季' : '进行中的赛季')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textOnScrimMuted)
        Text(this.item.title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnScrim)
        Text(`${this.item.sportType} · ${this.item.startDate} → ${this.item.endDate}`)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnScrimMuted)
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }

    Row({ space: Theme.space.s3 }) {
      this.MetaChip('次数进度', `${this.progress.sessions}/${this.item.targetSessions}`)
      this.MetaChip('完成度', `${this.progress.sessionPct}%`)
    }
    .width('100%')

    Column({ space: Theme.space.s2 }) {
      Text('挑战说明')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.item.note.length > 0 ? this.item.note : '用真实训练次数自动累计进度，不是摆设目标。')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })

    Column({ space: Theme.space.s3 }) {
      Text('计入本挑战的记录')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.related.length === 0) {
        Text('还没有落入日期区间的训练。去「记录」页完成一笔后，这里会自动出现。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.related, (r: SportRecord) => {
          SportListCard({
            record: r,
            onTap: (): void => {
              SportDetailNav.open(r.id)
            }
          })
        }, (r: SportRecord) => r.id)
      }
    }
    .width('100%')
  }

  @Builder
  MetaChip(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  FooterActions() {
    if (this.item.status !== 'done') {
      AppButton({
        label: this.progress.done ? '标记挑战完成' : '尚未达次数，仍可提前完成',
        onTap: (): void => {
          void this.markDone()
        }
      })
    }
    AppButton({
      label: this.confirmDelete ? '确认删除此挑战' : '删除挑战',
      variant: this.confirmDelete ? 'danger' : 'secondary',
      onTap: (): void => {
        void this.handleDelete()
      }
    })
  }

  private async markDone(): Promise<void> {
    const next = SportModelClone.challenge(this.item)
    next.status = 'done'
    await ChallengeStore.save(next)
    this.item = SportModelClone.challenge(next)
    this.progress = SportAnalytics.challengeProgress(this.item)
    this.onChanged()
  }

  private async handleDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await ChallengeStore.remove(this.item.id)
    this.onChanged()
    SportDetailNav.close()
  }
}
