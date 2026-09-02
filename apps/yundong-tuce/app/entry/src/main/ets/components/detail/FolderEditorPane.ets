import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { FavFolder, MoveItem } from '../../models/TuceModels'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

class FolderPickRow {
  id: string = ''
  name: string = ''
}

@Component
export struct FolderEditorPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop folderId: string = ''
  @State folderName: string = ''
  @State rows: FolderPickRow[] = []
  @State catalog: MoveItem[] = []
  @State errorText: string = ''

  aboutToAppear(): void {
    this.catalog = MoveLibrary.all()
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.folderId.length === 0) {
      this.folderName = '我的收藏夹'
      return
    }
    const list = await TuceStore.folders()
    for (const it of list) {
      if (it.id === this.folderId) {
        this.folderName = it.name
        const ids = MoveLibrary.splitIds(it.moveIds)
        const next: FolderPickRow[] = []
        for (const id of ids) {
          const m = MoveLibrary.find(id)
          if (m !== undefined) {
            const row = new FolderPickRow()
            row.id = m.id
            row.name = m.name
            next.push(row)
          }
        }
        this.rows = next
      }
    }
  }

  private addId(id: string): void {
    for (const r of this.rows) {
      if (r.id === id) {
        return
      }
    }
    const m = MoveLibrary.find(id)
    if (m === undefined) {
      return
    }
    const row = new FolderPickRow()
    row.id = m.id
    row.name = m.name
    const next: FolderPickRow[] = []
    for (const it of this.rows) {
      next.push(it)
    }
    next.push(row)
    this.rows = next
  }

  private removeAt(index: number): void {
    const next: FolderPickRow[] = []
    let i = 0
    for (const it of this.rows) {
      if (i !== index) {
        next.push(it)
      }
      i++
    }
    this.rows = next
  }

  private async save(): Promise<void> {
    if (this.folderName.trim().length === 0) {
      this.errorText = '请填写收藏夹名称'
      return
    }
    const folder = new FavFolder()
    folder.id = this.folderId.length > 0 ? this.folderId : TuceStore.newId('folder')
    folder.name = this.folderName.trim()
    const ids: string[] = []
    for (const r of this.rows) {
      ids.push(r.id)
    }
    folder.moveIds = ids.join('|')
    await TuceStore.saveFolder(folder)
    TuceNav.bump()
    TuceNav.close()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        TextInput({ text: this.folderName, placeholder: '收藏夹名称' })
          .onChange((v: string): void => { this.folderName = v })

        Text('收藏动作')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.rows, (row: FolderPickRow, index: number) => {
          Row({ space: Theme.space.s2 }) {
            Text(`${index + 1}. ${row.name}`)
              .fontSize(Theme.type.bodyS)
              .layoutWeight(1)
            Row() {
              Text('移除')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
            }
            .width(44)
            .height(36)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.removeAt(index) })
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
        }, (row: FolderPickRow) => row.id)

        Text('从图鉴添加')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.catalog, (m: MoveItem) => {
          Row() {
            Text(`${m.category} · ${m.name}`)
              .fontSize(Theme.type.bodyS)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.sm)
          .onClick((): void => { this.addId(m.id) })
        }, (m: MoveItem) => m.id)

        if (this.errorText.length > 0) {
          Text(this.errorText).fontSize(Theme.type.caption).fontColor(Theme.colors().danger)
        }
        AppButton({ label: '保存收藏夹', variant: 'primary', onTap: (): void => { void this.save() } })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s2,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Auto)
  }
}
