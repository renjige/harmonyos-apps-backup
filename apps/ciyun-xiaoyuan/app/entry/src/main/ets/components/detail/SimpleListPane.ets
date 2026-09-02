import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { CourtyardDetailNav } from '../../services/CourtyardDetailNav'
import { CourtyardLocalStore } from '../../services/CourtyardLocalStore'
import { FavoriteItem, WorkItem } from '../../models/CourtyardModels'
import { DetailShell } from './DetailShell'

@Component
export struct SimpleListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'favorites'
  onClose: () => void = () => {}

  private title(): string {
    if (this.kind === 'works') {
      return '个人作品'
    }
    if (this.kind === 'progress') {
      return '学习进度'
    }
    return '收藏夹'
  }

  build() {
    DetailShell({
      title: this.title(),
      onClose: (): void => { this.onClose() }
    }) {
      Column({ space: Theme.space.s3 }) {
        if (this.kind === 'works') {
          if (CourtyardLocalStore.works().length === 0) {
            AppEmpty({ title: '还没有作品', description: '在格律页检测后可保存习作' })
          }
          ForEach(CourtyardLocalStore.works(), (w: WorkItem) => {
            Column({ space: 4 }) {
              Text(w.title).fontSize(Theme.type.bodyM).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
              Text(w.meterSummary).fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).maxLines(2).width('100%')
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(8)
            .onClick((): void => { CourtyardDetailNav.openWork(w.id) })
          }, (w: WorkItem) => w.id)
        } else if (this.kind === 'progress') {
          Text(`已读篇目 ${CourtyardLocalStore.readCount()} 首`)
            .fontSize(Theme.type.bodyL)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(`格律检测 ${CourtyardLocalStore.detectCount()} 次`)
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text('进度保存在本机。新账号不会出现他人记录。')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        } else {
          if (CourtyardLocalStore.favorites().length === 0) {
            AppEmpty({ title: '收藏还是空的', description: '在诗词详情里点收藏' })
          }
          ForEach(CourtyardLocalStore.favorites(), (f: FavoriteItem) => {
            Text(f.poemId)
              .fontSize(Theme.type.bodyM)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(8)
              .onClick((): void => { CourtyardDetailNav.openPoem(f.poemId) })
          }, (f: FavoriteItem) => f.poemId)
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
  }
}
