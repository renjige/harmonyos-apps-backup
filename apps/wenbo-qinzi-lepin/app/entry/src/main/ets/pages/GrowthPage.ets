import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { PlayRecord } from '../models/JigsawModels'
import { JigsawNav } from '../services/JigsawNav'
import { JigsawMedia } from '../services/JigsawMedia'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('doneCount') doneCount: number = 0
  @StorageLink('starCount') starCount: number = 0
  @StorageLink('jigTick') @Watch('onTick') tick: number = 0
  @State records: PlayRecord[] = []
  @State observe: number = 0
  @State logic: number = 0
  @State focus: number = 0
  @State coord: number = 0
  @State maxPieces: number = 0

  aboutToAppear(): void {
    this.refresh()
  }

  onTick(): void {
    this.refresh()
  }

  private refresh(): void {
    const snap = ProgressStore.snapshot()
    this.records = snap.records
    this.observe = ProgressStore.observeScore()
    this.logic = ProgressStore.logicScore()
    this.focus = ProgressStore.focusScore()
    this.coord = ProgressStore.coordScore()
    let maxP = 0
    for (const r of snap.records) {
      if (r.pieces > maxP) {
        maxP = r.pieces
      }
    }
    this.maxPieces = maxP
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('成长记录')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Row({ space: 10 }) {
          this.StatCard('完成', `${this.doneCount}`)
          this.StatCard('星星', `${this.starCount}`)
          this.StatCard('最高块数', this.maxPieces > 0 ? `${this.maxPieces}` : '—')
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('能力小条（本机计算）')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          this.AbilityRow('观察力', this.observe, Theme.colors().brandAccent)
          this.AbilityRow('逻辑力', this.logic, Theme.colors().brandPrimary)
          this.AbilityRow('专注力', this.focus, Theme.colors().success)
          this.AbilityRow('手眼协调', this.coord, Theme.colors().warning)
          Text('只记录你在这台设备上的完成情况，不是测评，也没有排名。')
            .fontSize(13)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(20)

        Row() {
          Text('看看今天适合拼什么')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding(14)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(16)
        .onClick(() => { JigsawNav.setRoute(JigsawNav.DIAGNOSE) })

        Text('近期完成')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        if (this.records.length === 0) {
          AppEmpty({
            title: '还没有完成记录',
            description: '去乐园拼完一幅，就会出现在这里。'
          })
        } else {
          ForEach(this.records, (r: PlayRecord) => {
            Row({ space: 10 }) {
              Image(JigsawMedia.cover(r.coverKey.length > 0 ? r.coverKey : 'hero_desk'))
                .width(56)
                .height(56)
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
              Column({ space: 4 }) {
                Text(r.title)
                  .fontSize(15)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(`${r.themeLabel} · ${r.pieces} 块 · ${r.at}`)
                  .fontSize(12)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Text(`${r.stars} 颗星`)
                .fontSize(14)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            }
            .width('100%')
            .padding(10)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)
          }, (r: PlayRecord) => r.id)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s5,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear(() => { this.refresh() })
  }

  @Builder
  StatCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(16)
  }

  @Builder
  AbilityRow(label: string, value: number, color: string) {
    Column({ space: 4 }) {
      Row() {
        Text(label)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text(`${value}`)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')
      Stack({ alignContent: Alignment.Start }) {
        Column()
          .width('100%')
          .height(8)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(8)
        Column()
          .width(`${value}%`)
          .height(8)
          .backgroundColor(color)
          .borderRadius(8)
      }
      .width('100%')
      .height(8)
    }
    .width('100%')
  }
}
