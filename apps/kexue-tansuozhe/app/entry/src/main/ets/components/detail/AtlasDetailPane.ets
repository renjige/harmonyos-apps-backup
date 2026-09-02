import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AtlasCatalog, AtlasItem } from '../../data/AtlasCatalog'
import { ExplorationStore } from '../../services/ExplorationStore'
import { ExploreNav } from '../../services/ExploreNav'
import { ExploreToast } from '../../services/ExploreToast'
import { SymbolHero } from '../design-system/SymbolVisual'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct AtlasDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') @Watch('onRev') progressRev: number = 0
  @Prop atlasId: string = ''
  @State item: AtlasItem = new AtlasItem()
  @State noteText: string = ''
  @State status: string = 'unknown'
  @State fav: boolean = false
  onToast: (msg: string) => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    const found = ExplorationStore.getAtlasNote(this.atlasId)
    this.noteText = found.myNote
    this.status = found.status
    this.fav = ExplorationStore.isFavoriteAtlas(this.atlasId)
    const it = AtlasCatalog.findById(this.atlasId)
    if (it !== undefined) {
      this.item = it
    }
  }

  private async saveNote(): Promise<void> {
    await ExplorationStore.saveAtlasNote(this.atlasId, this.status, this.noteText)
    if (this.noteText.trim().length > 0) {
      await ExplorationStore.completeTask('task_note1')
    }
    if (this.status === 'known' || this.status === 'exploring') {
      await ExplorationStore.completeTask('task_status1')
    }
    this.onToast('笔记已保存')
    ExploreToast.show('笔记已保存')
  }

  private async toggleFav(): Promise<void> {
    this.fav = await ExplorationStore.toggleFavoriteAtlas(this.atlasId)
    if (this.fav) {
      await ExplorationStore.completeTask('task_favorite1')
    }
    const msg = this.fav ? '已加入收藏' : '已取消收藏'
    this.onToast(msg)
    ExploreToast.show(msg)
  }

  private setStatus(next: string): void {
    this.status = next
    void ExplorationStore.saveAtlasNote(this.atlasId, next, this.noteText).then((): void => {
      ExploreToast.show('探索状态已更新')
    })
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        SymbolHero({
          category: this.item.category,
          coverKey: this.item.id,
          bannerHeight: 220,
          overline: CategoryEmojiUtil.chipLabel(this.item.category),
          title: this.item.name,
          subtitle: this.item.summary
        })

        AppCard({ title: '简介', variant: 'outlined' }) {
          Text(this.item.summary)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(22)
            .width('100%')
        }

        AppCard({ title: '特征', variant: 'outlined' }) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.item.traits, (t: string) => {
              Text(t)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
            }, (t: string) => t)
          }
          .width('100%')
        }

        AppCard({ title: '趣味知识', variant: 'outlined' }) {
          Text(this.item.funFact)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(22)
            .width('100%')
        }

        Text('我的探索状态')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.StatusChip('unknown', '未了解')
          this.StatusChip('exploring', '待观察')
          this.StatusChip('known', '已了解')
        }
        .width('100%')

        Text('我的笔记')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        TextArea({ text: this.noteText, placeholder: '写下你的观察与联想…' })
          .width('100%')
          .height(100)
          .fontSize(Theme.type.body)
          .backgroundColor(Theme.colors().surfaceCard)
          .onChange((v: string): void => { this.noteText = v })

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: '保存笔记',
              variant: 'primary',
              onTap: (): void => { void this.saveNote() }
            })
          }
          .layoutWeight(1)
          Column() {
            AppButton({
              label: this.fav ? '已收藏' : '收藏',
              variant: 'secondary',
              onTap: (): void => { void this.toggleFav() }
            })
          }
          .layoutWeight(1)
        }
        .width('100%')

        Column() {
          AppButton({
            label: '关联到我的探索记录',
            variant: 'secondary',
            onTap: (): void => {
              ExploreNav.closeAtlasDetail()
              ExploreNav.openNewRecord()
            }
          })
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
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
  }

  @Builder
  StatusChip(value: string, label: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.status === value ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.status === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.setStatus(value) })
  }
}
