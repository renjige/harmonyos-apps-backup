import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { DetailShell } from './DetailShell'
import { CreateFavoriteRequest, JournalItem, UpdateDiaryRequest } from '../../models/JournalModels'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalDetailNav } from '../../services/JournalDetailNav'
import { AuthService } from '../../services/AuthService'
import { CoverPhotoField } from '../journal/CoverPhotoField'

@Component
export struct DiaryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onDataChanged: () => void = () => {}
  @State item: JournalItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  @State showEdit: boolean = false
  @State showDeleteConfirm: boolean = false
  @State formTitle: string = ''
  @State formDestination: string = ''
  @State formBody: string = ''
  @State formTags: string = ''
  @State formDate: string = ''
  @State formCoverKey: string = ''
  @State saving: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await JournalBizService.findDiary(this.itemId)
    this.loading = false
  }

  private parseTags(raw: string): string[] {
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private openEdit(): void {
    if (this.item === undefined) {
      return
    }
    this.formTitle = this.item.title
    this.formDestination = this.item.subtitle
    this.formBody = this.item.body
    this.formTags = this.item.tags.join(', ')
    this.formDate = this.item.recordDate
    this.formCoverKey = this.item.coverKey.length > 0 ? this.item.coverKey : ''
    this.showEdit = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeEdit(): void {
    this.showEdit = false
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private async saveEdit(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.showToast('请填写旅程名称')
      return
    }
    this.saving = true
    const req = new UpdateDiaryRequest()
    req.title = this.formTitle.trim()
    req.subtitle = this.formDestination.trim()
    req.body = this.formBody.trim()
    req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
    req.tags = this.parseTags(this.formTags)
    req.recordDate = this.formDate
    req.coverKey = this.formCoverKey
    req.imageKeys = [this.formCoverKey]
    req.userId = this.currentUsername
    const updated = await JournalBizService.updateDiary(this.item.id, req)
    this.saving = false
    if (updated !== undefined) {
      this.item = updated
      this.closeEdit()
      this.onDataChanged()
      this.showToast('已保存修改')
    } else {
      this.showToast('保存失败')
    }
  }

  private async confirmDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const ok = await JournalBizService.deleteDiary(this.item.id, this.currentUsername)
    this.showDeleteConfirm = false
    if (ok) {
      this.onDataChanged()
      JournalDetailNav.close()
    } else {
      this.showToast('删除失败')
    }
  }

  private async handleFavorite(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const req = new CreateFavoriteRequest()
    req.kind = 'text'
    req.title = this.item.title
    req.content = this.item.body.length > 0 ? this.item.body : this.item.summary
    const created = await JournalBizService.createFavorite(req)
    if (created !== undefined) {
      this.showToast('已加入旅行收藏')
      this.onDataChanged()
    } else {
      this.showToast('收藏失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载札记…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '札记不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '我的札记',
          onClose: () => JournalDetailNav.close(),
          body: () => { this.DetailBody() }
        })
      }

      if (this.showEdit) {
        this.EditOverlay()
      }

      if (this.showDeleteConfirm) {
        Column() {
          Column({ space: Theme.space.s4 }) {
            Text('确认删除这篇札记？')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text('删除后不可恢复')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textSecondary)
            Row({ space: Theme.space.s2 }) {
              AppButton({
                label: '取消',
                variant: 'ghost',
                onTap: (): void => { this.showDeleteConfirm = false }
              }).layoutWeight(1)
              AppButton({
                label: '删除',
                variant: 'secondary',
                onTap: (): void => { void this.confirmDelete() }
              }).layoutWeight(1)
            }.width('100%')
          }
          .padding(Theme.space.s5)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .width('88%')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(26,58,82,0.45)')
        .zIndex(35)
      }

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
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(JournalMedia.resolveImage(
            this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_travel_home'
          ))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(92,107,115,0)', 0], ['rgba(92,107,115,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.recordDate.length > 0 ? this.item.recordDate : '旅行札记')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(this.item.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.item.summary.length > 0) {
          Column() {
            AppCard({ title: '摘要', variant: 'plain' }) {
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '正文', variant: 'plain' }) {
            Text(this.item.body.length > 0 ? this.item.body : '（无正文）')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s2 }) {
          AppButton({
            label: '加入旅行收藏',
            variant: 'secondary',
            onTap: (): void => { void this.handleFavorite() }
          })
          AppButton({
            label: '编辑札记',
            variant: 'ghost',
            onTap: (): void => { this.openEdit() }
          })
          AppButton({
            label: '删除札记',
            variant: 'ghost',
            onTap: (): void => { this.showDeleteConfirm = true }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }

  @Builder
  EditOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Text('编辑札记')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.formTitle, placeholder: '旅程名称' })
            .width('100%').height(44)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTitle = v })
          TextInput({ text: this.formDestination, placeholder: '目的地' })
            .width('100%').height(44)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formDestination = v })
          AppDatePickerField({
            label: '日期',
            value: this.formDate,
            minDaysFromToday: -3650,
            maxDaysFromToday: 365,
            onChange: (v: string) => { this.formDate = v }
          })
          TextArea({ text: this.formBody, placeholder: '正文' })
            .width('100%').height(140)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formBody = v })
          TextInput({ text: this.formTags, placeholder: '标签，逗号分隔' })
            .width('100%').height(44)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTags = v })
          CoverPhotoField({
            coverKey: this.formCoverKey,
            onCoverChange: (key: string): void => { this.formCoverKey = key },
            onPickError: (msg: string): void => { this.showToast(msg) }
          })
          Row({ space: Theme.space.s2 }) {
            AppButton({
              label: '取消',
              variant: 'ghost',
              onTap: (): void => { this.closeEdit() }
            }).layoutWeight(1)
            AppButton({
              label: this.saving ? '保存中…' : '保存',
              disabled: this.saving,
              onTap: (): void => { void this.saveEdit() }
            }).layoutWeight(1)
          }.width('100%')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(30)
  }
}
