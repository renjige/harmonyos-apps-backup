import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { CaseItem } from '../../models/CourtModels'
import { CourtMedia } from '../../config/CourtMedia'
import { CourtBizService } from '../../services/CourtBizService'
import { CourtDetailNav } from '../../services/CourtDetailNav'

@Component
export struct CaseDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop caseId: string = ''
  @State item: CaseItem = new CaseItem()
  @State loading: boolean = true
  onBookSame: (category: string) => void = (_c: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    const found = await CourtBizService.findCase(this.caseId)
    if (found !== undefined) {
      this.item = found
    }
    this.loading = false
  }

  build() {
    DetailShell({
      title: '球友实记',
      onClose: (): void => {
        CourtDetailNav.close()
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
    if (this.loading) {
      Text('加载中…')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
    } else {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(CourtMedia.byKey(this.item.coverKey))
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
        Column({ space: 0 })
          .width('100%')
          .height(200)
          .borderRadius(Theme.radius.xl)
          .linearGradient({
            angle: 180,
            colors: [
              ['rgba(26,42,58,0.08)', 0.0],
              ['rgba(26,42,58,0.90)', 1.0]
            ]
          })
        Column({ space: 6 }) {
          Text(this.item.category)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }

      AppCard({ title: '摘要', variant: 'plain' }) {
        Text(this.item.summary.length > 0 ? this.item.summary : '球友分享的到场体验')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }

      Column({ space: Theme.space.s2 }) {
        Text('完整记录')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        if (this.item.district.length > 0) {
          Text(this.item.district)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
        }
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
    }
  }

  @Builder
  FooterActions() {
    AppButton({
      label: '预约同类场馆',
      onTap: (): void => {
        this.onBookSame(this.item.category)
      }
    })
  }
}
