import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { PoemListCard } from '../design-system/PoetryCards'
import { HuntNote, HuntRecord, MedalItem, PoemItem } from '../../models/PoetryModels'
import { PoetryBizService } from '../../services/PoetryBizService'
import { PoetryMedia } from '../../services/PoetryMedia'
import { PoetryNav } from '../../services/PoetryNav'
import { HuntProgressStore } from '../../services/HuntProgressStore'

@Component
export struct FavoritesPanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State poems: PoemItem[] = []
  onBack: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const all = await PoetryBizService.loadPoems()
    const out: PoemItem[] = []
    const favs = HuntProgressStore.snapshot().favorites
    for (const id of favs) {
      const p = PoetryBizService.findPoem(all, id)
      if (p !== undefined) {
        out.push(p)
      }
    }
    this.poems = out
  }

  build() {
    Column() {
      this.Head('我的收藏')
      if (this.poems.length === 0) {
        AppEmpty({ title: '还没有收藏', description: '在诗词详情中点收藏，列表会出现在这里' })
      } else {
        List({ space: 12 }) {
          ForEach(this.poems, (p: PoemItem) => {
            ListItem() {
              PoemListCard({
                dynasty: p.dynasty,
                title: p.title,
                author: p.author,
                summary: p.summary,
                cover: PoetryMedia.cover(p.coverKey),
                onOpen: () => PoetryNav.openPoem(p.id)
              })
            }
          }, (p: PoemItem) => p.id)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 24 })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Head(title: string) {
    Row() {
      Text('返回')
        .fontSize(15)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .onClick(() => this.onBack())
      Blank()
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
      Blank()
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 12 })
  }
}

@Component
export struct NotesPanel {
  onBack: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.onBack())
        Blank()
        Text('我的笔记')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      if (HuntProgressStore.snapshot().notes.length === 0) {
        AppEmpty({ title: '还没有笔记', description: '在诗词详情中写下感受后会出现在这里' })
      } else {
        List({ space: 12 }) {
          ForEach(HuntProgressStore.snapshot().notes, (n: HuntNote) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(n.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(n.body)
                  .fontSize(14)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(n.at)
                  .fontSize(12)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .padding(16)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(16)
              .width('100%')
              .onClick(() => PoetryNav.openPoem(n.poemId))
            }
          }, (n: HuntNote) => n.poemId)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 24 })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}

@Component
export struct RecordsPanel {
  onBack: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.onBack())
        Blank()
        Text('闯关进度')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      if (HuntProgressStore.snapshot().records.length === 0) {
        AppEmpty({ title: '还没有通关记录', description: '完成一关后会出现在这里' })
      } else {
        List({ space: 10 }) {
          ForEach(HuntProgressStore.snapshot().records, (r: HuntRecord) => {
            ListItem() {
              Row() {
                Column({ space: 4 }) {
                  Text(r.title)
                    .fontSize(16)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(`${r.at} · +${r.coins} 诗币`)
                    .fontSize(13)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .padding(16)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(16)
              .width('100%')
            }
          }, (r: HuntRecord) => `${r.levelId}-${r.at}`)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}

@Component
export struct MedalsPanel {
  @State medals: MedalItem[] = []
  onBack: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.medals = await PoetryBizService.loadMedals()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.onBack())
        Blank()
        Text('成就徽章')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      if (this.medals.length === 0) {
        AppEmpty({
          title: '徽章尚未载入',
          description: '请检查网络后重试',
          actionLabel: '重试',
          onAction: () => { void this.reload() }
        })
      } else {
        List({ space: 10 }) {
          ForEach(this.medals, (m: MedalItem) => {
            ListItem() {
              Row({ space: 12 }) {
                Image(PoetryMedia.cover(m.coverKey))
                  .width(56)
                  .height(56)
                  .borderRadius(12)
                  .objectFit(ImageFit.Cover)
                  .opacity(HuntProgressStore.isMedalOn(m.id) ? 1 : 0.4)
                Column({ space: 4 }) {
                  Text(m.title)
                    .fontSize(16)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(HuntProgressStore.isMedalOn(m.id) ? '已获得' : m.summary)
                    .fontSize(13)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .padding(14)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(16)
              .width('100%')
            }
          }, (m: MedalItem) => m.id)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
