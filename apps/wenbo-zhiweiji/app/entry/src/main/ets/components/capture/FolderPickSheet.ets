import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { KnowledgeFolder } from '../../models/ZhiweiModels'
import { ZhiweiStore } from '../../services/ZhiweiStore'

@Component
export struct FolderPickSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State folders: KnowledgeFolder[] = []
  onPick: (id: string, name: string) => void = (id: string, name: string) => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.folders = ZhiweiStore.folders()
  }

  build() {
    Column() {
      Column()
        .width('100%')
        .layoutWeight(1)
        .onClick(() => this.onClose())
      Column({ space: Theme.space.s3 }) {
        Text('加入知识库专题')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .width('100%')
        ForEach(this.folders, (f: KnowledgeFolder) => {
          Row() {
            Text(f.name)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .layoutWeight(1)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colorOf(this.themeEpoch).textTertiary })
          }
          .width('100%')
          .constraintSize({ minHeight: 48 })
          .onClick(() => this.onPick(f.id, f.name))
        }, (f: KnowledgeFolder) => f.id)
        Text('取消')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(Theme.space.s3)
          .onClick(() => this.onClose())
      }
      .width('100%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
      .borderRadius({ topLeft: Theme.radius.sheet, topRight: Theme.radius.sheet })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().overlayScrim)
  }
}
