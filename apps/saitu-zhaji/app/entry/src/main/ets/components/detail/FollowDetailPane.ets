import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { SportEvent, SportFollow } from '../../models/SaituSportModels'
import { SaituSportStore } from '../../services/SaituSportStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'
import { SportEventCard } from '../sport/SportEventCard'

@Component
export struct FollowDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituFollowDetailId') @Watch('onIdChange') followId: string = ''
  onChanged: () => void = () => {}
  @State item: SportFollow = new SportFollow()
  @State related: SportEvent[] = []
  @State editName: string = ''
  @State editNote: string = ''
  @State editRole: string = 'team'
  @State editing: boolean = false
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    const found = await SaituSportStore.findFollow(this.followId)
    if (found !== undefined) {
      this.item = found
      this.editName = found.name
      this.editNote = found.note
      this.editRole = found.role
      this.related = await SaituSportStore.eventsMatchingName(found.name)
    }
  }

  private async saveEdit(): Promise<void> {
    if (this.editName.trim().length === 0) {
      this.showToast('名称不能为空')
      return
    }
    this.item.name = this.editName.trim()
    this.item.note = this.editNote.trim()
    this.item.role = this.editRole
    await SaituSportStore.saveFollow(this.item)
    this.editing = false
    await this.reload()
    this.onChanged()
    this.showToast('已保存')
  }

  private async doDelete(): Promise<void> {
    await SaituSportStore.deleteFollow(this.item.id)
    this.confirmDelete = false
    SaituDetailNav.closeFollowDetail()
    this.onChanged()
  }

  @Builder
  bodyContent() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Column({ space: Theme.space.s2 }) {
          Text(this.item.roleLabel())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandOnPrimary)
          Text(this.item.name)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
            .width('100%')
          if (this.item.note.length > 0) {
            Text(this.item.note)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textOnInverse)
              .width('100%')
          }
        }
        .width('100%')
        .padding(Theme.space.s5)
        .linearGradient({
          angle: 150,
          colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
        })
        .borderRadius(Theme.radius.lg)

        if (this.editing) {
          TextInput({ text: this.editName, placeholder: '名称' })
            .onChange((v: string): void => { this.editName = v })
          TextInput({ text: this.editNote, placeholder: '备注' })
            .onChange((v: string): void => { this.editNote = v })
          Row({ space: Theme.space.s2 }) {
            Text('球队')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.editRole === 'team' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.editRole === 'team' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.editRole = 'team' })
            Text('选手')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.editRole === 'player' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.editRole === 'player' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.editRole = 'player' })
          }
          AppButton({ label: '保存', variant: 'primary', onTap: (): void => { void this.saveEdit() } })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.editing = false } })
        } else {
          Column({ space: Theme.space.s3 }) {
            AppButton({ label: '编辑资料', variant: 'secondary', onTap: (): void => { this.editing = true } })
            AppButton({
              label: '新建关联赛事记录',
              variant: 'primary',
              onTap: (): void => {
                SaituDetailNav.closeFollowDetail()
                SaituDetailNav.openNewSportEditor('record', '')
              }
            })
            AppButton({ label: '移除关注', variant: 'secondary', onTap: (): void => { this.confirmDelete = true } })
          }
          .width('100%')
        }

        Text(`相关赛事档案 · ${this.related.length}`)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.related.length === 0) {
          AppEmpty({
            title: '暂无关联档案',
            description: '创建赛事记录时在标题或对阵中写上该名称即可自动关联'
          })
        } else {
          ForEach(this.related, (e: SportEvent) => {
            SportEventCard({
              item: e,
              onTap: (): void => {
                SaituDetailNav.closeFollowDetail()
                SaituDetailNav.openSportDetail(e.id)
              }
            })
          }, (e: SportEvent) => e.id)
        }
        Blank().height(Theme.space.s10)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .scrollBar(BarState.Off)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '关注详情',
        onClose: (): void => SaituDetailNav.closeFollowDetail(),
        body: (): void => this.bodyContent()
      })
      if (this.confirmDelete) {
        Column({ space: Theme.space.s3 }) {
          Text('确认移除该关注？')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
          AppButton({ label: '确认移除', variant: 'danger', onTap: (): void => { void this.doDelete() } })
        }
        .width('80%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .position({ x: '10%', y: '32%' })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
