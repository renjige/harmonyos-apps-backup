import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { KnowledgeFolder } from '../models/ZhiweiModels'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct LibraryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwRev') @Watch('onRev') storeRev: number = 0
  @State folders: KnowledgeFolder[] = []
  @State newName: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.folders = ZhiweiStore.folders()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private countOf(id: string): number {
    return ZhiweiStore.capturesInFolder(id).length
  }

  private async createNow(): Promise<void> {
    const ok = await ZhiweiStore.createFolder(this.newName)
    if (ok) {
      this.newName = ''
      this.reload()
      this.showToast('已新建专题')
      return
    }
    this.showToast('请填写专题名称')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick(() => ZhiweiNav.closeLibrary())
          Text('个人知识库')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('把微知识收进专题，形成自己的读书笔记、生活技巧与学习资料。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            TextInput({ text: this.newName, placeholder: '新建专题名称，如「我的观察笔记」' })
              .width('100%')
              .height(44)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.newName = v })
            AppButton({
              label: '创建专题',
              variant: 'primary',
              onTap: (): void => { void this.createNow() }
            })
            AppButton({
              label: '打开知识收藏夹',
              variant: 'secondary',
              onTap: (): void => {
                ZhiweiNav.closeLibrary()
                ZhiweiNav.openFocus('fav', '', '知识收藏夹')
              }
            })
            if (this.folders.length === 0) {
              AppEmpty({
                title: '还没有专题',
                description: '创建一个合集，把相关微知识放在一起。'
              })
            } else {
              ForEach(this.folders, (f: KnowledgeFolder) => {
                Row() {
                  Column({ space: 4 }) {
                    Text(f.name)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                      .width('100%')
                    Text(`${this.countOf(f.id)} 条微知识`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colorOf(this.themeEpoch).textTertiary })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
                .borderRadius(Theme.radius.card)
                .onClick(() => {
                  ZhiweiNav.closeLibrary()
                  ZhiweiNav.openFocus('folder', f.id, f.name)
                })
              }, (f: KnowledgeFolder) => f.id)
            }
            Blank().height(Theme.space.s10)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: 48 })
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .id(`lib_${this.themeEpoch}`)
  }
}
