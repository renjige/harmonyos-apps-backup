import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppIcon } from '../design-system/AppIcon'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { CoverPhotoPicker } from '../inspiration/CoverPhotoPicker'
import { InspirationCoverImage } from '../inspiration/InspirationCoverImage'
import { DetailShell } from './DetailShell'
import { CreateFavoriteRequest, InspirationItem, LinkedRef, LinkedRefList, UpdateInspirationRequest } from '../../models/InspirationModels'
import { InspirationBizService } from '../../services/InspirationBizService'
import { InspirationDetailNav } from '../../services/InspirationDetailNav'
import { PhotoPickService } from '../../services/PhotoPickService'
import { AuthService } from '../../services/AuthService'
import { common } from '@kit.AbilityKit'

@Component
export struct InspirationDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRouteChange') itemId: string = ''
  @Prop @Watch('onRouteChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onInspirationChanged: () => void = () => {}
  @State item: InspirationItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  @State showEdit: boolean = false
  @State confirmDelete: boolean = false
  @State editTitle: string = ''
  @State editBody: string = ''
  @State editTags: string = ''
  @State editDate: string = ''
  @State editCoverKey: string = ''
  @State saving: boolean = false
  @State showLinkPicker: boolean = false
  @State linkPickerKind: string = 'plan'
  @State linkCandidates: InspirationItem[] = []
  @State linkedRefs: LinkedRef[] = []
  @State linkedItems: InspirationItem[] = []
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onRouteChange(): void {
    void this.loadItem()
  }

  private async loadItem(): Promise<void> {
    if (this.itemId.length === 0) {
      this.item = undefined
      this.linkedRefs = []
      this.linkedItems = []
      this.loading = false
      return
    }
    this.loading = true
    this.item = await InspirationBizService.findInspiration(this.itemId)
    if (this.item !== undefined) {
      this.linkedRefs = LinkedRefList.parse(this.item.linkedIdsJson)
      this.linkedItems = await InspirationBizService.resolveLinkedItems(this.currentUsername, this.item.linkedIdsJson)
    } else {
      this.linkedRefs = []
      this.linkedItems = []
    }
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private isMine(): boolean {
    if (this.item === undefined) {
      return false
    }
    return this.item.userId === this.currentUsername && this.currentUsername.length > 0
  }

  private async showLinkTargetPicker(kind: string): Promise<void> {
    if (!this.isMine()) {
      return
    }
    this.linkPickerKind = kind
    if (kind === 'board') {
      this.linkCandidates = await InspirationBizService.loadMoodBoards(this.currentUsername)
    } else {
      this.linkCandidates = await InspirationBizService.loadCreativePlans(this.currentUsername)
    }
    this.showLinkPicker = true
  }

  private async attachLink(targetId: string): Promise<void> {
    if (this.item === undefined) {
      return
    }
    this.saving = true
    const req = new UpdateInspirationRequest()
    req.title = this.item.title
    req.body = this.item.body
    req.summary = this.item.summary
    req.tags = this.item.tags
    req.recordDate = this.item.recordDate
    req.coverKey = this.item.coverKey
    req.linkedIdsJson = LinkedRefList.add(this.item.linkedIdsJson, this.linkPickerKind, targetId)
    const updated = await InspirationBizService.updateInspiration(this.item.id, req)
    this.saving = false
    this.showLinkPicker = false
    if (updated !== undefined) {
      this.item = updated
      this.linkedRefs = LinkedRefList.parse(updated.linkedIdsJson)
      this.linkedItems = await InspirationBizService.resolveLinkedItems(this.currentUsername, updated.linkedIdsJson)
      this.onInspirationChanged()
      this.showToast('已建立关联')
    } else {
      this.showToast('关联失败，请稍后重试')
    }
  }

  private linkedTitle(ref: LinkedRef): string {
    for (const row of this.linkedItems) {
      if (row.id === ref.id) {
        return InspirationItem.displayTitle(row)
      }
    }
    return LinkedRefList.kindLabel(ref.kind)
  }

  private navigateLinkedRefByKey(kind: string, id: string): void {
    if (id.length === 0) {
      this.showToast('关联内容无效')
      return
    }
    InspirationDetailNav.navigateTo(kind, id)
  }

  private navigateLinkedRef(ref: LinkedRef): void {
    this.navigateLinkedRefByKey(ref.kind, ref.id)
  }

  private openEdit(): void {
    if (this.item === undefined) {
      return
    }
    this.editTitle = this.item.title
    this.editBody = this.item.body
    this.editTags = this.item.tags.join(', ')
    this.editDate = this.item.recordDate
    this.editCoverKey = this.item.coverKey
    this.showEdit = true
  }

  private toggleEditCover(key: string): void {
    if (this.editCoverKey === key) {
      this.editCoverKey = ''
    } else {
      this.editCoverKey = key
    }
  }

  private async pickEditCover(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    const key = await PhotoPickService.pickOne(ctx)
    if (key.length > 0) {
      this.editCoverKey = key
    }
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

  private async saveEdit(): Promise<void> {
    if (this.item === undefined || this.editTitle.trim().length === 0) {
      this.showToast('请填写标题')
      return
    }
    this.saving = true
    const req = new UpdateInspirationRequest()
    req.title = this.editTitle.trim()
    req.body = this.editBody.trim()
    req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
    req.tags = this.parseTags(this.editTags)
    req.recordDate = this.editDate
    req.coverKey = this.editCoverKey.length > 0 ? this.editCoverKey : 'hero_latest_inspiration'
    req.linkedIdsJson = this.item.linkedIdsJson
    const updated = await InspirationBizService.updateInspiration(this.item.id, req)
    this.saving = false
    if (updated !== undefined) {
      this.item = updated
      this.showEdit = false
      this.onInspirationChanged()
      this.showToast('已保存修改')
    } else {
      const hint = InspirationBizService.lastError.length > 0 ? InspirationBizService.lastError : '请稍后重试'
      this.showToast(`保存失败：${hint}`)
    }
  }

  private async deleteItem(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    this.saving = true
    const ok = await InspirationBizService.deleteInspiration(this.item.id)
    this.saving = false
    if (ok) {
      this.onInspirationChanged()
      InspirationDetailNav.close()
    } else {
      this.showToast('删除失败，请稍后重试')
    }
    this.confirmDelete = false
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
    req.kind = this.item.coverKey.length > 0 ? 'image' : 'text'
    req.title = this.item.title
    req.content = this.item.body.length > 0 ? this.item.body : this.item.summary
    req.coverKey = this.item.coverKey
    const created = await InspirationBizService.createFavorite(req)
    if (created !== undefined) {
      this.showToast('已加入灵感收藏')
    } else {
      this.showToast('收藏失败，请稍后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        if (this.loading) {
          AppLoading({ label: '加载灵感…' })
        } else if (this.item === undefined) {
          AppEmpty({ title: '灵感不存在', description: '可能已被删除或网络异常' })
        } else {
          DetailShell({
            title: '我的灵感',
            onClose: () => InspirationDetailNav.close(),
            body: () => { this.DetailBody() }
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.showEdit) {
        this.EditOverlay()
      }

      if (this.confirmDelete) {
        this.DeleteConfirmOverlay()
      }

      if (this.showLinkPicker) {
        this.LinkPickerOverlay()
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
          InspirationCoverImage({
            coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_latest_inspiration',
            imageWidth: '100%',
            imageHeight: 200,
            useAspectRatio: false,
            cornerRadius: Theme.radius.xl,
            imageFit: ImageFit.Cover
          })
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,42,65,0)', 0], ['rgba(27,42,65,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.recordDate.length > 0 ? this.item.recordDate : '灵感记录')
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
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
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
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
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
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          if (this.linkedRefs.length > 0) {
            Text('关联创作')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.linkedRefs, (ref: LinkedRef) => {
              Column() {
                Row({ space: Theme.space.s3 }) {
                  Text(LinkedRefList.kindLabel(ref.kind))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width(40)
                  Text(this.linkedTitle(ref))
                    .fontSize(Theme.type.callout)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                    .maxLines(2)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { this.navigateLinkedRefByKey(ref.kind, ref.id) })
            }, (ref: LinkedRef) => `${ref.kind}_${ref.id}`)
          }
          AppButton({
            label: '加入灵感收藏',
            variant: 'secondary',
            onTap: (): void => { void this.handleFavorite() }
          })
          if (this.isMine()) {
            AppButton({
              label: '关联到计划',
              variant: 'secondary',
              onTap: (): void => { void this.showLinkTargetPicker('plan') }
            })
            AppButton({
              label: '关联到画板',
              variant: 'secondary',
              onTap: (): void => { void this.showLinkTargetPicker('board') }
            })
            AppButton({
              label: '编辑灵感',
              onTap: (): void => { this.openEdit() }
            })
            AppButton({
              label: '删除灵感',
              variant: 'secondary',
              onTap: (): void => { this.confirmDelete = true }
            })
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }

  @Builder
  EditOverlay() {
    Column() {
      Row() {
        Text('编辑灵感')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Text('取消')
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick((): void => { this.showEdit = false })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.editTitle, placeholder: '标题' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.editTitle = v })
          AppDatePickerField({
            label: '记录日期',
            value: this.editDate,
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => { this.editDate = v }
          })
          TextArea({ text: this.editBody, placeholder: '正文' })
            .width('100%')
            .height(140)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.editBody = v })
          TextInput({ text: this.editTags, placeholder: '标签，逗号分隔' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.editTags = v })
          CoverPhotoPicker({
            selectedKeys: this.editCoverKey.length > 0 ? [this.editCoverKey] : [],
            maxCount: 1,
            showBuiltin: true,
            galleryLabel: '从相册换封面',
            onToggle: (key: string): void => { this.toggleEditCover(key) },
            onPickGallery: (): void => { void this.pickEditCover() }
          })
          AppButton({
            label: this.saving ? '保存中…' : '保存修改',
            disabled: this.saving,
            onTap: (): void => { void this.saveEdit() }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(30)
  }

  @Builder
  LinkPickerOverlay() {
    Column() {
      Row() {
        Text(`关联到${LinkedRefList.kindLabel(this.linkPickerKind)}`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Text('关闭')
          .fontColor(Theme.colors().textSecondary)
          .onClick((): void => { this.showLinkPicker = false })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.linkCandidates.length === 0) {
            AppEmpty({ title: '暂无可关联内容', description: '请先创建画板或计划' })
          } else {
            ForEach(this.linkCandidates, (row: InspirationItem) => {
              Column({ space: Theme.space.s2 }) {
                Text(InspirationItem.displayTitle(row))
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                  .maxLines(2)
                if (row.summary.length > 0 || row.goal.length > 0) {
                  Text(row.summary.length > 0 ? row.summary : row.goal)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                    .maxLines(2)
                }
                AppButton({
                  label: this.saving ? '…' : '关联',
                  disabled: this.saving,
                  onTap: (): void => { void this.attachLink(row.id) }
                })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { void this.attachLink(row.id) })
            }, (row: InspirationItem) => row.id)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(35)
  }

  @Builder
  DeleteConfirmOverlay() {
    Column({ space: Theme.space.s4 }) {
      Text('确定删除这条灵感？')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
      Text('删除后无法恢复。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: this.saving ? '删除中…' : '确认删除',
            disabled: this.saving,
            onTap: (): void => { void this.deleteItem() }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('88%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .zIndex(45)
  }
}
