import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { RecordListCard } from '../components/saitu/RecordListCard'
import { SaituRecord, DateGroup } from '../models/SaituModels'
import { SaituLocalStore } from '../services/SaituLocalStore'
import { SaituDetailNav } from '../services/SaituDetailNav'

@Component
export struct RecordsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State records: SaituRecord[] = []
  @State journeyNames: Map<string, string> = new Map()
  @State groups: DateGroup[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.records = await SaituLocalStore.loadRecords()
    const journeys = await SaituLocalStore.loadJourneys()
    const map = new Map<string, string>()
    for (const j of journeys) {
      map.set(j.id, j.name)
    }
    this.journeyNames = map
    this.groups = DateGroup.groupRecords(this.records)
    this.loading = false
  }

  private journeyLabel(id: string): string {
    const name = this.journeyNames.get(id)
    return name !== undefined ? name : ''
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_ambient'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(168)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0.55)', 0], ['rgba(0,0,0,0.25)', 0.4], ['rgba(0,0,0,0.72)', 1]]
            })
          Column({ space: 4 }) {
            Text('赛途札记')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('成长札记 + 个人赛事档案')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
          }
          .padding(Theme.space.pageX)
          .margin({ bottom: Theme.space.s4 })
        }
        .width('100%')

        if (this.loading) {
          Blank().layoutWeight(1)
        } else if (this.records.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有札记',
              description: '点击右下角 + 写下第一条赛途记录'
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              ForEach(this.groups, (g: DateGroup) => {
                Column({ space: Theme.space.s2 }) {
                  Text(g.label)
                    .fontSize(Theme.type.overline)
                    .fontColor(Theme.colors().textTertiary)
                    .width('100%')
                  ForEach(g.records, (r: SaituRecord) => {
                    RecordListCard({
                      record: r,
                      journeyName: this.journeyLabel(r.journeyId),
                      onTap: (): void => SaituDetailNav.openRecord(r.id)
                    })
                  }, (r: SaituRecord) => r.id)
                }
              }, (g: DateGroup) => g.dateKey)
              Blank().height(this.bottomInset + Theme.space.s10)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(28)
      .margin({ right: Theme.space.pageX, bottom: this.bottomInset + Theme.space.s3 })
      .shadow({ radius: 12, color: 'rgba(0,122,255,0.35)', offsetY: 4 })
      .onClick((): void => SaituDetailNav.openNewEditor())
    }
    .width('100%')
    .height('100%')
  }
}
