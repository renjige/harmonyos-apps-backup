import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { CottageItem } from '../../models/CottageModels'
import { CottageBizService } from '../../services/CottageBizService'
import { CottageMedia } from '../../services/CottageMedia'
import { CottageNav } from '../../services/CottageNav'

@Component
export struct PathDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entityId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State path: CottageItem = new CottageItem()
  @State lessons: CottageItem[] = []
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.entityId.length === 0) {
      this.loaded = false
      return
    }
    const found = await CottageBizService.findPath(this.entityId)
    if (found === undefined) {
      this.loaded = false
      return
    }
    this.path = found
    this.lessons = await CottageBizService.loadLessons(found.id)
    this.loaded = true
  }

  private metaLine(): string {
    const days = this.path.days > 0 ? `${this.path.days} 日` : ''
    const minutes = this.path.minutes > 0 ? `每课约 ${this.path.minutes} 分钟` : ''
    const diff = this.path.difficulty
    return `${this.path.categoryLabel} · ${days} · ${minutes} · ${diff}`
  }

  private openFirstLesson(): void {
    if (this.lessons.length === 0) {
      return
    }
    CottageNav.openLesson(this.lessons[0].id)
  }

  build() {
    DetailShell({
      title: '学习路径',
      onClose: (): void => { CottageNav.closeDetail() }
    }) {
      if (!this.loaded) {
        AppEmpty({ title: '路径不存在', description: '请返回后刷新重试' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(CottageMedia.resource(this.path.coverKey))
                .width('100%')
                .height(210)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(210)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(18,32,58,0.08)', 0.25], ['rgba(18,32,58,0.82)', 1]]
                })
              Column({ space: 6 }) {
                Text(this.path.categoryLabel)
                  .fontSize(Theme.type.caption)
                  .fontColor('#F8FAFC')
                Text(this.path.title)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F8FAFC')
                  .maxLines(2)
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.md)
            .clip(true)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text(this.metaLine())
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column() {
              Text(this.path.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .lineHeight(24)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text(this.path.description.length > 0 ? this.path.description : this.path.body)
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(28)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text('课时序列')
              .fontSize(Theme.type.subtitleL)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column({ space: Theme.space.s3 }) {
              ForEach(this.lessons, (lesson: CottageItem, idx: number) => {
                Row({ space: Theme.space.s3 }) {
                  Text(`${idx + 1}`)
                    .fontSize(Theme.type.subtitleL)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width(28)
                  Column({ space: 4 }) {
                    Text(lesson.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(2)
                    Text(lesson.minutes > 0 ? `约 ${lesson.minutes} 分钟` : lesson.subtitle)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick((): void => { CottageNav.openLesson(lesson.id) })
              }, (lesson: CottageItem) => lesson.id)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column() {
              AppButton({
                label: '开始第一节课',
                onTap: (): void => { this.openFirstLesson() }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
    }
  }
}
