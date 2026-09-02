import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppButton } from '../design-system/AppButton'
import { FavFolder, MoveItem } from '../../models/TuceModels'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'
import { MoveListCard } from '../tuce/MoveListCard'

@Component
export struct FavoritesPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tuceReload') @Watch('onReload') reloadToken: number = 0
  @State folders: FavFolder[] = []
  @State favMoves: MoveItem[] = []
  @State tab: number = 0

  aboutToAppear(): void {
    void this.load()
  }

  onReload(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.folders = await TuceStore.folders()
    const ids = await TuceStore.favIds()
    const moves: MoveItem[] = []
    for (const id of ids) {
      const m = MoveLibrary.find(id)
      if (m !== undefined) {
        moves.push(m)
      }
    }
    this.favMoves = moves
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        Row({ space: Theme.space.s2 }) {
          Text('全部收藏')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.tab === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.tab === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.tab = 0 })
          Text('收藏夹')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.tab === 1 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.tab === 1 ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.tab = 1 })
        }
        .width('100%')

        if (this.tab === 0) {
          if (this.favMoves.length === 0) {
            AppEmpty({
              title: '还没有收藏动作',
              description: '在图鉴中点击动作详情，收藏喜欢的训练',
              actionLabel: '知道了',
              onAction: (): void => { TuceNav.close() }
            })
          }
          ForEach(this.favMoves, (m: MoveItem) => {
            MoveListCard({
              moveId: m.id,
              name: m.name,
              meta: `${m.category} · ${m.level}`,
              coverKey: m.coverKey
            })
          }, (m: MoveItem) => m.id)
        } else {
          AppButton({
            label: '新建收藏夹',
            variant: 'primary',
            onTap: (): void => { TuceNav.open('folderedit', '') }
          })
          ForEach(this.folders, (f: FavFolder) => {
            Column({ space: Theme.space.s2 }) {
              Text(f.name)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(MoveLibrary.namesOf(f.moveIds))
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { TuceNav.open('folderedit', f.id) })
          }, (f: FavFolder) => f.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }
}
