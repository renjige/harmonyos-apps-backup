import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AthleteListCard } from '../components/sports/AthleteListCard'
import { EventListCard } from '../components/sports/EventListCard'
import { AthleteItem, EventItem } from '../models/StarModels'
import { StarBizService } from '../services/StarBizService'
import { StarDetailNav } from '../services/StarDetailNav'
import { StarMedia } from '../services/StarMedia'
import { SportCategoryOption } from '../components/sports/SportCategoryBar'

@Component
export struct SportHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop sportKey: string = 'football'
  @Prop @Watch('onSportChange') refreshToken: number = 0
  @State athletes: AthleteItem[] = []
  @State events: EventItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onSportChange(): void {
    void this.reload()
  }

  private sportLabel(): string {
    const opts = SportCategoryOption.all()
    for (const opt of opts) {
      if (opt.key === this.sportKey) {
        return opt.label
      }
    }
    return '体育'
  }

  private hubCover(): Resource {
    if (this.sportKey === 'football') {
      return StarMedia.coverMedia('cat_football')
    }
    if (this.sportKey === 'basketball') {
      return StarMedia.coverMedia('cat_basketball')
    }
    if (this.sportKey === 'tennis') {
      return StarMedia.coverMedia('cat_tennis')
    }
    if (this.sportKey === 'racing') {
      return StarMedia.coverMedia('cat_racing')
    }
    return StarMedia.coverMedia('hero_sports_discovery')
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.athletes = await StarBizService.loadAthletes(this.sportKey, false)
    this.events = await StarBizService.loadEvents(this.sportKey, '', 'upcoming')
    this.loading = false
  }

  private openAthlete(id: string): void {
    StarDetailNav.pushAthlete(id)
  }

  private openEvent(id: string): void {
    StarDetailNav.pushEvent(id)
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { StarDetailNav.close() })
        Text(`${this.sportLabel()}专区`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '加载专区…' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(this.hubCover())
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Column()
                .width('100%')
                .height(140)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(15,23,42,0.08)', 0], ['rgba(15,23,42,0.78)', 1]]
                })
                .borderRadius(Theme.radius.xl)
              Column({ space: 4 }) {
                Text(`${this.sportLabel()}人物与赛程`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textOnInverse)
                Text(`${this.athletes.length} 位球星 · ${this.events.length} 场未开始赛事`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textOnInverse)
              }
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text('球星名录')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (this.athletes.length === 0) {
                AppEmpty({ title: '暂无球星', description: '该分类数据稍后更新' })
              } else {
                ForEach(this.athletes, (item: AthleteItem) => {
                  Column() {
                    AthleteListCard({
                      item: item,
                      compact: true,
                      onTap: (): void => { this.openAthlete(item.id) }
                    })
                  }
                  .width('100%')
                  .onClick((): void => { this.openAthlete(item.id) })
                }, (item: AthleteItem) => item.id)
              }
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text('近期赛程')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (this.events.length === 0) {
                AppEmpty({ title: '暂无赛程', description: '可关注球星后在详情设置提醒' })
              } else {
                ForEach(this.events.slice(0, 6), (ev: EventItem) => {
                  Column() {
                    EventListCard({
                      item: ev,
                      compact: true,
                      onTap: (): void => { this.openEvent(ev.id) }
                    })
                  }
                  .width('100%')
                  .onClick((): void => { this.openEvent(ev.id) })
                }, (ev: EventItem) => ev.id)
              }
            }
            .width('100%')
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
