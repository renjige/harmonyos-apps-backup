import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { EssayListCard } from '../components/essay/EssayListCard'
import { EssayItem } from '../models/EssayModels'
import { DawnMedia } from '../services/DawnMedia'
import { EssayDateUtil } from '../services/EssayDateUtil'
import { EssayNav } from '../services/EssayNav'
import { EssayStore } from '../services/EssayStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: EssayItem[] = []
  @State monthMode: boolean = false
  @State filterIso: string = ''
  @State greet: string = '早安，记录今日'
  @State dateLine: string = ''
  @State monthLabel: string = ''
  @State monthDays: number[] = []
  @State marked: string[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    const d = new Date()
    this.greet = EssayDateUtil.greet()
    this.dateLine = `${EssayDateUtil.homeTitle(d)}  ${EssayDateUtil.weekdayLabel(d)}`
    this.monthLabel = `${d.getFullYear()}年${d.getMonth() + 1}月`
    this.marked = EssayStore.datesInMonth(d.getFullYear(), d.getMonth() + 1)
    this.monthDays = HomePage.buildDays(d.getFullYear(), d.getMonth() + 1)
    if (this.filterIso.length > 0) {
      this.items = EssayStore.byDate(this.filterIso)
    } else {
      this.items = EssayStore.active()
    }
  }

  private static buildDays(year: number, month: number): number[] {
    const last = new Date(year, month, 0).getDate()
    const out: number[] = []
    for (let i = 1; i <= last; i++) {
      out.push(i)
    }
    return out
  }

  private isoOf(day: number): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  private isMarked(day: number): boolean {
    const iso = this.isoOf(day)
    for (const x of this.marked) {
      if (x === iso) {
        return true
      }
    }
    return false
  }

  build() {
    Stack() {
      Column() {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(DawnMedia.cover('hero_dawn_window'))
                .width('100%')
                .height(210)
                .objectFit(ImageFit.Cover)
              Column({ space: 6 }) {
                Text(this.greet)
                  .fontSize(Theme.type.title1)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .width('100%')
                Text(this.dateLine)
                  .fontSize(Theme.type.subhead)
                  .fontColor('#FFFFFF')
                  .width('100%')
              }
              .width('100%')
              .padding({ left: 20, right: 20, bottom: 18 })
              .linearGradient({
                angle: 180,
                colors: [['rgba(61,50,40,0)', 0], ['rgba(61,50,40,0.78)', 1]]
              })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .borderRadius(Theme.radius.lg)
            .clip(true)

            Image(DawnMedia.cover('banner_letter_desk'))
              .width('100%')
              .height(110)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)

            Row() {
              Text(this.filterIso.length > 0 ? '这一天的笺' : '笺集')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Row({ space: 8 }) {
                AppIcon({
                  name: 'list',
                  iconSize: Theme.icon.md,
                  color: !this.monthMode ? Theme.colors().brandPrimary : Theme.colors().textSecondary
                })
                  .onClick((): void => {
                    this.monthMode = false
                    this.filterIso = ''
                    this.reload()
                  })
                AppIcon({
                  name: 'calendar',
                  iconSize: Theme.icon.md,
                  color: this.monthMode ? Theme.colors().brandPrimary : Theme.colors().textSecondary
                })
                  .onClick((): void => {
                    this.monthMode = true
                    this.reload()
                  })
              }
            }
            .width('100%')

            if (this.monthMode) {
              Text(this.monthLabel)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.monthDays, (day: number) => {
                  Column({ space: 4 }) {
                    Text(`${day}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.filterIso === this.isoOf(day) ?
                        Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    if (this.isMarked(day)) {
                      Circle({ width: 6, height: 6 })
                        .fill(Theme.colors().brandAccent)
                    }
                  }
                  .width('14%')
                  .height(48)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.filterIso === this.isoOf(day) ?
                    Theme.colors().brandPrimary : Color.Transparent)
                  .borderRadius(Theme.radius.sm)
                  .onClick((): void => {
                    this.filterIso = this.isoOf(day)
                    this.monthMode = false
                    this.reload()
                  })
                }, (day: number) => `d-${day}`)
              }
              .width('100%')
            }

            if (this.items.length === 0) {
              Column({ space: Theme.space.s3 }) {
                Image(DawnMedia.cover('empty_first_jian'))
                  .width('100%')
                  .height(160)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                AppEmpty({
                  title: '今日尚无笺，写下第一笔吧',
                  description: '点右下角，把此刻折进一张信笺。',
                  actionLabel: '写新笺',
                  onAction: (): void => { EssayNav.openWrite('') }
                })
              }
              .width('100%')
            } else {
              ForEach(this.items, (it: EssayItem) => {
                EssayListCard({
                  item: it,
                  onTap: (): void => { EssayNav.openDetail('essay', it.id) }
                })
              }, (it: EssayItem) => it.id)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .borderRadius(28)
      .backgroundColor(Theme.colors().brandPrimary)
      .justifyContent(FlexAlign.Center)
      .shadow({ radius: 16, color: 'rgba(166,124,82,0.35)', offsetY: 4 })
      .margin({ right: Theme.space.pageX, bottom: 18 })
      .onClick((): void => { EssayNav.openWrite('') })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.BottomEnd)
  }
}
