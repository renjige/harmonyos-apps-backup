import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { HandcraftWork } from '../../models/HandcraftModels'
import { CreateWorkRequest, UpdateWorkRequest } from '../../models/HandcraftModels'
import { HandcraftBizService } from '../../services/HandcraftBizService'
import { CraftMedia } from '../../services/CraftMedia'

/** 全屏作品创建/编辑表单 */
@Component
export struct WorkEditOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editWork: HandcraftWork | undefined = undefined
  @Prop categories: string[] = []
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State title: string = ''
  @State category: string = '纸艺'
  @State coverKey: string = 'cover_work_1'
  @State summary: string = ''
  @State description: string = ''
  @State materialsText: string = ''
  @State stepsText: string = ''
  @State notes: string = ''
  @State tagsText: string = ''
  @State saving: boolean = false
  @State errorText: string = ''

  aboutToAppear(): void {
    if (this.editWork !== undefined) {
      this.title = this.editWork.title
      this.category = this.editWork.category
      this.coverKey = this.editWork.coverKey
      this.summary = this.editWork.summary
      this.description = this.editWork.description
      this.materialsText = this.joinLines(this.editWork.materials)
      this.stepsText = this.joinLines(this.editWork.steps)
      this.notes = this.editWork.notes
      this.tagsText = this.joinLines(this.editWork.tags)
    } else {
      const pendingTitle = AppStorage.get<string>('pendingWorkTitle') ?? ''
      if (pendingTitle.length > 0) {
        this.title = pendingTitle
        const pendingCat = AppStorage.get<string>('pendingWorkCategory') ?? ''
        if (pendingCat.length > 0) {
          this.category = pendingCat
        }
        const pendingCover = AppStorage.get<string>('pendingWorkCover') ?? ''
        if (pendingCover.length > 0) {
          this.coverKey = pendingCover
        }
        AppStorage.setOrCreate('pendingWorkTitle', '')
        AppStorage.setOrCreate('pendingWorkCategory', '')
        AppStorage.setOrCreate('pendingWorkCover', '')
      }
    }
    if (this.categories.length > 0 && this.category.length === 0) {
      this.category = this.categories[0]
    }
  }

  private joinLines(arr: string[]): string {
    let out = ''
    for (let i = 0; i < arr.length; i++) {
      if (i > 0) {
        out += '\n'
      }
      out += arr[i]
    }
    return out
  }

  private splitLines(text: string): string[] {
    const raw = text.split('\n')
    const out: string[] = []
    for (const line of raw) {
      const t = line.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private async handleSave(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写作品名称'
      return
    }
    this.saving = true
    this.errorText = ''
    if (this.editWork !== undefined && this.editWork.id.length > 0) {
      const req = new UpdateWorkRequest()
      req.title = this.title.trim()
      req.category = this.category
      req.coverKey = this.coverKey
      req.summary = this.summary.trim()
      req.description = this.description.trim()
      req.materials = this.splitLines(this.materialsText)
      req.steps = this.splitLines(this.stepsText)
      req.notes = this.notes.trim()
      req.tags = this.splitLines(this.tagsText)
      const updated = await HandcraftBizService.updateWork(this.editWork.id, req)
      this.saving = false
      if (updated !== undefined) {
        this.onSaved()
        this.onClose()
      } else {
        this.errorText = '保存失败，请稍后重试'
      }
    } else {
      const req = new CreateWorkRequest()
      req.title = this.title.trim()
      req.category = this.category
      req.coverKey = this.coverKey
      req.summary = this.summary.trim()
      req.description = this.description.trim()
      req.materials = this.splitLines(this.materialsText)
      req.steps = this.splitLines(this.stepsText)
      req.notes = this.notes.trim()
      req.tags = this.splitLines(this.tagsText)
      const created = await HandcraftBizService.createWork(req)
      this.saving = false
      if (created !== undefined) {
        this.onSaved()
        this.onClose()
      } else {
        this.errorText = '发布失败，请检查登录状态'
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.onClose())
          Text(this.editWork !== undefined ? '编辑作品' : '新建作品')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
          Column() {
            AppButton({
              label: this.saving ? '…' : '保存',
              variant: 'primary',
              disabled: this.saving,
              onTap: (): void => { void this.handleSave() }
            })
          }.width(88)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
        }

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            this.FieldLabel('作品名称')
            TextInput({ text: this.title, placeholder: '给作品起个温暖的名字' })
              .onChange((v: string) => { this.title = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .padding(Theme.space.s3)

            this.FieldLabel('分类')
            Row({ space: Theme.space.s2 }) {
              ForEach(this.categories, (cat: string) => {
                Text(cat)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.category === cat ?
                    Theme.colors().textOnInverse : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.category === cat ?
                    Theme.colors().brandDeep : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    this.category = cat
                    this.coverKey = CraftMedia.defaultCoverForCategory(cat)
                  })
              }, (cat: string) => cat)
            }.width('100%')

            this.FieldLabel('封面（点选切换）')
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(CraftMedia.coverOptions(), (key: string) => {
                Column({ space: 4 }) {
                  Image(CraftMedia.byKey(key))
                    .width(72)
                    .height(72)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.md)
                    .border({
                      width: this.coverKey === key ? 2 : 1,
                      color: this.coverKey === key ?
                        Theme.colors().brandPrimary : Theme.colors().strokeHairline
                    })
                  Text(CraftMedia.coverLabel(key))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.coverKey === key ?
                      Theme.colors().brandDeep : Theme.colors().textSecondary)
                    .maxLines(1)
                }
                .width('23%')
                .margin({ bottom: Theme.space.s2 })
                .onClick((): void => { this.coverKey = key })
              }, (key: string) => key)
            }.width('100%')

            this.FieldLabel('一句话摘要')
            TextInput({ text: this.summary, placeholder: '用一句话描述这件作品' })
              .onChange((v: string) => { this.summary = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .padding(Theme.space.s3)

            this.FieldLabel('详细说明')
            TextArea({ text: this.description, placeholder: '制作过程、风格与亮点…' })
              .height(100)
              .onChange((v: string) => { this.description = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .padding(Theme.space.s3)

            this.FieldLabel('材料（每行一项）')
            TextArea({ text: this.materialsText, placeholder: '棉纸\n干压花\n和纸胶带' })
              .height(80)
              .onChange((v: string) => { this.materialsText = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .padding(Theme.space.s3)

            this.FieldLabel('步骤（每行一步）')
            TextArea({ text: this.stepsText, placeholder: '第一步…\n第二步…' })
              .height(100)
              .onChange((v: string) => { this.stepsText = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .padding(Theme.space.s3)

            this.FieldLabel('创作心得')
            TextArea({ text: this.notes, placeholder: '记录这次创作的心情与体会' })
              .height(80)
              .onChange((v: string) => { this.notes = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .padding(Theme.space.s3)

            this.FieldLabel('标签（每行一个）')
            TextArea({ text: this.tagsText, placeholder: '手账\n纸艺\n莫兰迪' })
              .height(60)
              .onChange((v: string) => { this.tagsText = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .padding(Theme.space.s3)

            Column().height(Theme.space.s10)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s2,
            bottom: Theme.space.s2
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')

      Column() {
        AppButton({
          label: this.saving ? '保存中…' : (this.editWork !== undefined ? '保存修改' : '发布作品'),
          disabled: this.saving,
          onTap: (): void => { void this.handleSave() }
        })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s10
      })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  FieldLabel(text: string) {
    Text(text)
      .fontSize(Theme.type.subhead)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      .width('100%')
  }
}
