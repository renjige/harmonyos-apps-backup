import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DestItem } from '../../models/EscapeModels'
import { EscapeBizService } from '../../services/EscapeBizService'
import { EscapeDetailNav } from '../../services/EscapeDetailNav'
import { EscapeMedia } from '../../services/EscapeMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct DestDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onDestIdChange') destId: string = ''
  @Prop @Watch('onDestIdChange') refreshToken: number = 0
  @State item: DestItem | undefined = undefined
  @State loading: boolean = true
  @State favored: boolean = false
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onDestIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await EscapeBizService.findDest(this.destId)
    this.favored = await EscapeBizService.isFavored(this.destId)
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async toggleFav(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    this.favored = await EscapeBizService.toggleFavorite('destination', this.item.id, this.item.title, this.item.coverKey)
    this.showToast(this.favored ? '已收藏这座避暑地' : '已取消收藏')
  }

  private writeJournal(): void {
    if (!AuthService.requireAuth('create_journal')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    EscapeDetailNav.openJournalNew(this.item.id, this.item.title, this.item.coverKey)
  }

  private current(): DestItem {
    if (this.item !== undefined) {
      return this.item
    }
    return new DestItem()
  }

  private tagsText(): string {
    if (this.item === undefined) {
      return ''
    }
    let s = ''
    for (const t of this.item.tags) {
      if (s.length > 0) {
        s += '  ·  '
      }
      s += t
    }
    return s
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '打开这座山' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '目的地', onClose: () => EscapeDetailNav.close() }) {
          AppEmpty({ title: '这座地方暂时看不见', description: '刷新后再试', actionLabel: '重试', onAction: () => { void this.reload() } })
        }
      } else {
        DetailShell({ title: this.item.title, contentKey: this.item.id, onClose: () => EscapeDetailNav.close() }) {
          this.Body()
        }
      }
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(EscapeMedia.resource(this.current().coverKey))
          .width('100%')
          .height(240)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(120)
          .linearGradient({
            angle: 180,
            colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.72)', 1]]
          })
        Column({ space: 4 }) {
          Text(this.current().title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F8FAFC')
          Text(`${this.current().city} · ${this.current().tempLabel()}`)
            .fontSize(Theme.type.body)
            .fontColor('#F8FAFC')
        }
        .padding(16)
      }
      .width('100%')
      .height(240)
      .borderRadius(Theme.radius.lg)
      .clip(true)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: 8 }) {
        Text(`${this.current().categoryLabel()} · ${this.current().altitude} · 推荐 ${this.current().score}/5`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.tagsText())
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: 8 }) {
        Text('为什么凉快')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.current().summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .padding(16)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(Theme.colors().surfaceGlass)
      .borderRadius(Theme.radius.md)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .alignItems(HorizontalAlign.Start)

      Column({ space: 10 }) {
        Text('详细说明')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.current().body)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(`最佳季节  ${this.current().season}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(`怎么去  ${this.current().transport}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(`当地吃  ${this.current().foods}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(`可看  ${this.current().spots}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .alignItems(HorizontalAlign.Start)

      Column({ space: 10 }) {
        AppButton({
          label: '写下这篇游记',
          onTap: (): void => { this.writeJournal() }
        })
        AppButton({
          label: this.favored ? '取消收藏' : '收藏这座避暑地',
          variant: 'secondary',
          onTap: (): void => { void this.toggleFav() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
  }
}
