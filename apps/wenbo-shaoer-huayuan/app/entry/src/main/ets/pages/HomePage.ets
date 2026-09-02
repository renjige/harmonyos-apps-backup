import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ArtworkItem, ChildItem } from '../models/KagModels'
import { KagBizService } from '../services/KagBizService'
import { KagMedia } from '../services/KagMedia'
import { KagNav } from '../services/KagNav'
import { AuthService } from '../services/AuthService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '少儿画苑'
  @Prop tagline: string = ''
  @StorageLink('kagTick') @Watch('onTick') tick: number = 0
  @StorageLink('kagChildId') childId: string = ''
  @StorageLink('accessToken') token: string = ''
  @State works: ArtworkItem[] = []
  @State children: ChildItem[] = []
  @State loading: boolean = false
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.children = await KagBizService.loadChildren()
    this.works = await KagBizService.loadWorks(this.childId, '', '')
    this.loading = false
  }

  private yearCount(): string {
    return `${this.works.length}`
  }

  private monthCount(): string {
    return `${KagBizService.thisMonthCount(this.works)}`
  }

  private tryUpload(): void {
    if (!AuthService.requireAuth('upload_artwork')) {
      this.onRequireAuth()
      return
    }
    KagNav.openBare('form')
  }

  private selectChild(id: string): void {
    AppStorage.setOrCreate('kagChildId', id)
    KagNav.bump()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Row() {
              AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick(() => KagNav.openBare('search'))
          }
          .width('100%')

          if (this.children.length > 0) {
            Scroll() {
              Row({ space: Theme.space.s2 }) {
                this.ChildChip('', '全部')
                ForEach(this.children, (c: ChildItem) => {
                  this.ChildChip(c.id, c.title)
                }, (c: ChildItem) => c.id)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }

          Stack({ alignContent: Alignment.BottomStart }) {
            Image(KagMedia.cover('hero_gallery'))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column()
              .width('100%')
              .height(220)
              .borderRadius(Theme.radius.lg)
              .linearGradient({
                angle: 180,
                colors: [[0x00000000, 0.18], [0xE64A2A1C, 1.0]]
              })
            Column({ space: 8 }) {
              Text(this.tagline)
                .fontSize(Theme.type.body)
                .fontColor('#FFF8F3')
                .width('100%')
              AppButton({
                label: '珍藏一幅',
                variant: 'primary',
                onTap: () => this.tryUpload()
              })
            }
            .width('100%')
            .padding({
              left: Theme.space.s4,
              right: Theme.space.s4,
              bottom: Theme.space.s4
            })
          }
          .width('100%')
          .height(220)
          .clip(true)

          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text(this.yearCount())
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text('已珍藏作品')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            Column({ space: 4 }) {
              Text(this.monthCount())
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().success)
              Text('本月新作')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }
          .width('100%')

          Text('成长时间线')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.works.length === 0) {
            Column({ space: Theme.space.s3 }) {
              Image(KagMedia.cover('empty_easel'))
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
              AppEmpty({
                title: this.token.length > 0 ? '还没有作品' : '登录后开始珍藏',
                description: '拍下今天的画，写下创作故事，时间线会替你记住。',
                actionLabel: '珍藏一幅',
                onAction: () => this.tryUpload()
              })
            }
          } else {
            ForEach(this.works, (w: ArtworkItem) => {
              this.TimelineCard(w)
            }, (w: ArtworkItem) => w.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)

      Column() {
        Blank()
        Row() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor(Theme.colors().brandPrimary)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.tryUpload())
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.End)
      .padding({ right: Theme.space.pageX, bottom: Theme.space.s6 })
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  ChildChip(id: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.childId === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.childId === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .constraintSize({ minHeight: 36 })
      .onClick(() => this.selectChild(id))
  }

  @Builder
  TimelineCard(w: ArtworkItem) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        Column()
          .width(10)
          .height(10)
          .borderRadius(5)
          .backgroundColor(Theme.colors().brandPrimary)
        Column()
          .width(2)
          .layoutWeight(1)
          .backgroundColor(Theme.colors().strokeStrong)
      }
      .width(12)
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      Column({ space: 8 }) {
        Text(w.createdOn.length > 0 ? w.createdOn : '日期未填')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        if (w.imageFile.length > 0) {
          Image(w.imageFile)
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
        } else {
          Image(KagMedia.cover(w.coverKey))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
        }
        Text(w.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(w.ageLabel.length > 0 ? w.ageLabel : '点开看故事')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .padding({ bottom: Theme.space.s4 })
    }
    .width('100%')
    .onClick(() => KagNav.open('work', w.id))
  }
}
