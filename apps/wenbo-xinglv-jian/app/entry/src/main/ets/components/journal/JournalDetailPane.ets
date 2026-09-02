import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { JournalEntry } from '../../models/JournalModels'
import { JianMedia } from '../../services/JianMedia'
import { TripStore } from '../../services/TripStore'
import { TripNav } from '../../services/TripNav'
import { AppToast } from '../../services/AppToast'

@Component
export struct JournalDetailPane {
  @StorageLink('detailJournalId') @Watch('onId') journalId: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onTok') refreshToken: number = 0
  @State item: JournalEntry = new JournalEntry()
  @State showConfirm: boolean = false

  aboutToAppear(): void {
    this.load()
  }

  onId(): void {
    this.load()
  }

  onTok(): void {
    this.load()
  }

  private load(): void {
    const j = TripStore.findJournal(this.journalId)
    if (j !== undefined) {
      this.item = j
    }
  }

  private async remove(): Promise<void> {
    await TripStore.removeJournal(this.journalId)
    TripNav.closeJournalDetail()
    AppToast.show('记录已删除')
  }

  build() {
    Stack() {
      Column() {
        AppNavBar({
          title: '旅迹详情',
          onBack: (): void => { TripNav.closeJournalDetail() }
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(JianMedia.cover(this.item.coverKey))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Column()
                .width('100%')
                .height(200)
                .borderRadius(Theme.radius.lg)
                .linearGradient({
                  angle: 180,
                  colors: [[Theme.heroScrimTop(this.darkModeOn), 0], [Theme.heroScrimBottom(this.darkModeOn), 1]]
                })
              Column({ space: 4 }) {
                Text(this.item.tagLabel())
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
                Text(this.item.title)
                  .fontSize(Theme.type.titleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .maxLines(2)
              }
              .align(Alignment.BottomStart)
              .margin({ left: 16, right: 16, bottom: 16 })
            }
            AppCard({ title: '摘要' }) {
              Text(`${this.item.recordDate} · ${this.item.location.length > 0 ? this.item.location : '未标注地点'}`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.palette(this.darkModeOn).textSecondary)
            }
            Text(this.item.body.length > 0 ? this.item.body : '暂无正文内容')
              .fontSize(Theme.type.bodyL)
              .fontColor(Theme.palette(this.darkModeOn).textPrimary)
              .lineHeight(26)
              .width('100%')
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '编辑',
                variant: 'secondary',
                onTap: (): void => {
                  AppStorage.setOrCreate('journalFormId', this.journalId)
                  AppStorage.setOrCreate('showJournalForm', true)
                  AppStorage.setOrCreate('detailJournalId', '')
                }
              })
                .layoutWeight(1)
              AppButton({
                label: '删除',
                variant: 'secondary',
                onTap: (): void => { this.showConfirm = true }
              })
                .layoutWeight(1)
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)

      if (this.showConfirm) {
        Column() {
          Column({ space: Theme.space.s4 }) {
            Text('确认删除这条旅迹？')
              .fontSize(Theme.type.subtitleM)
              .fontColor(Theme.palette(this.darkModeOn).textPrimary)
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '取消',
                variant: 'secondary',
                onTap: (): void => { this.showConfirm = false }
              })
                .layoutWeight(1)
              AppButton({
                label: '删除',
                onTap: (): void => { void this.remove() }
              })
                .layoutWeight(1)
            }
            .width('100%')
          }
          .width('86%')
          .padding(Theme.space.s6)
          .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
          .borderRadius(Theme.radius.lg)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.palette(this.darkModeOn).overlayScrim)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
