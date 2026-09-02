import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { ResearchBar } from '../../components/research/ResearchBar'
import { ResearchSandboxImage } from '../../components/research/ResearchSandboxImage'
import { ResearchNote } from '../../models/ResearchModels'
import { LanguageCraftMedia } from '../../services/LanguageCraftMedia'
import { ResearchNav } from '../../services/ResearchNav'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct NoteListPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: ResearchNote[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await ResearchStore.listNotes()
  }

  build() {
    Column() {
      ResearchBar({ title: '研究笔记' })
      Column() {
        AppButton({
          label: '新建主题笔记',
          onTap: (): void => { ResearchNav.openNoteEditor('') }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有笔记',
          description: '记录学习心得、阅读感悟、项目过程或兴趣研究。新用户列表为空。',
          actionLabel: '写第一条',
          onAction: (): void => { ResearchNav.openNoteEditor('') }
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (n: ResearchNote) => {
              Row({ space: Theme.space.s3 }) {
                if (n.photoPath.length > 0) {
                  ResearchSandboxImage({ srcPath: n.photoPath, imgWidth: 72, imgHeight: 72, radius: Theme.radius.sm })
                } else {
                  Image(LanguageCraftMedia.cover(n.coverKey.length > 0 ? n.coverKey : 'cover_library'))
                    .width(72)
                    .height(72)
                    .borderRadius(Theme.radius.sm)
                    .objectFit(ImageFit.Cover)
                }
                Column({ space: 4 }) {
                  Text(n.title.length > 0 ? n.title : '未命名笔记')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .maxLines(1)
                    .width('100%')
                  Text(n.viewpoint.length > 0 ? n.viewpoint : n.body)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .maxLines(2)
                    .width('100%')
                  Text(ResearchStore.timeLabel(n.updatedAt))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
              .onClick((): void => { ResearchNav.openNoteDetail(n.id) })
            }, (n: ResearchNote) => n.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
  }
}
