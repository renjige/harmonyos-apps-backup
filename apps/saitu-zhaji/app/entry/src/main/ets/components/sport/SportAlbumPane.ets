import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppEmpty } from '../design-system/AppEmpty'
import { SportAlbum, SportEvent } from '../../models/SaituSportModels'
import { SaituSportStore } from '../../services/SaituSportStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'
import { SportEventCard } from './SportEventCard'

@Component
export struct SportAlbumEditor {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituAlbumEditorId') @Watch('onIdChange') albumId: string = ''
  onSaved: () => void = () => {}
  @State title: string = ''
  @State description: string = ''
  @State toastText: string = ''
  @State isEdit: boolean = false
  private editing: SportAlbum = new SportAlbum()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  onIdChange(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    if (this.albumId.length > 0) {
      const found = await SaituSportStore.findAlbum(this.albumId)
      if (found !== undefined) {
        this.editing = found
        this.title = found.title
        this.description = found.description
        this.isEdit = true
        return
      }
    }
    this.editing = SportAlbum.create()
    this.title = ''
    this.description = ''
    this.isEdit = false
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请填写纪念册名称'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    this.editing.title = this.title.trim()
    this.editing.description = this.description.trim()
    await SaituSportStore.saveAlbum(this.editing)
    SaituDetailNav.closeAlbumEditor()
    this.onSaved()
  }

  build() {
    Column() {
      AppNavBar({
        title: this.isEdit ? '编辑纪念册' : '新建纪念册',
        onBack: (): void => SaituDetailNav.closeAlbumEditor()
      })
      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.title, placeholder: '如：我的世界杯记忆' })
          .fontSize(Theme.type.body)
          .onChange((v: string): void => { this.title = v })
        TextArea({ text: this.description, placeholder: '这本纪念册想收藏哪一段体育回忆？' })
          .height(120)
          .fontSize(Theme.type.body)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .onChange((v: string): void => { this.description = v })
        AppButton({ label: '保存纪念册', variant: 'primary', onTap: (): void => { void this.save() } })
        if (this.toastText.length > 0) {
          Text(this.toastText).fontSize(Theme.type.bodyS).fontColor(Theme.colors().danger)
        }
      }
      .padding(Theme.space.pageX)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}

@Component
export struct SportAlbumDetail {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituAlbumDetailId') @Watch('onIdChange') albumId: string = ''
  onChanged: () => void = () => {}
  @State album: SportAlbum = new SportAlbum()
  @State events: SportEvent[] = []
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await SaituSportStore.findAlbum(this.albumId)
    if (found !== undefined) {
      this.album = found
    }
    const all = await SaituSportStore.loadEvents()
    const out: SportEvent[] = []
    for (const e of all) {
      if (e.albumId === this.albumId) {
        out.push(e)
      }
    }
    this.events = out
  }

  private async doDelete(): Promise<void> {
    await SaituSportStore.deleteAlbum(this.album.id)
    this.confirmDelete = false
    SaituDetailNav.closeAlbumDetail()
    this.onChanged()
  }

  build() {
    Column() {
      AppNavBar({
        title: this.album.title.length > 0 ? this.album.title : '纪念册',
        onBack: (): void => SaituDetailNav.closeAlbumDetail()
      })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text(this.album.description.length > 0 ? this.album.description : '把重要赛事收进这本专题。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '向本册添加赛事记录',
            variant: 'primary',
            onTap: (): void => SaituDetailNav.openNewSportEditor('record', this.album.id)
          })
          AppButton({
            label: '编辑纪念册',
            variant: 'secondary',
            onTap: (): void => SaituDetailNav.openAlbumEditor(this.album.id)
          })
          if (this.events.length === 0) {
            AppEmpty({ title: '册内还没有赛事', description: '点上方按钮写入第一条回忆' })
          } else {
            ForEach(this.events, (e: SportEvent) => {
              SportEventCard({ item: e, onTap: (): void => SaituDetailNav.openSportDetail(e.id) })
            }, (e: SportEvent) => e.id)
          }
          if (!this.confirmDelete) {
            AppButton({
              label: '删除纪念册',
              variant: 'ghost',
              onTap: (): void => { this.confirmDelete = true }
            })
          } else {
            Column({ space: Theme.space.s2 }) {
              Text('删除后册内赛事仍保留，仅取消归属。')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
              AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
              AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.doDelete() } })
            }
          }
          Blank().height(Theme.space.s10)
        }
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
